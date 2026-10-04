import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;

/// NVIDIA RTX Video Super Resolution açık mı. Ayarlar'dan değişir ve
/// [SettingsStore] ile saklanır; açık oynatıcılar hemen uyar.
final rtxVsr = ValueNotifier<bool>(false);

/// VSR yalnız Windows'ta, D3D11 video işlemcisiyle çalışır.
bool get rtxVsrSupported => Platform.isWindows;

/// Oynatıcıya uygulamanın libmpv ayarlarını verir; ilk açılıştan önce
/// beklenmeli.
///
/// media_kit'in varsayılan `demuxer-lavf-o` değeri `strict=experimental`
/// içerir. Bu açıkken WebVTT altyazı listesi olan HLS yayınları (ör. Pluto TV
/// kanalları) hiç başlamıyor. Aynı değer bu seçenek olmadan verilir.
Future<void> configurePlayer(Player player) async {
  final platform = player.platform;
  if (platform is! NativePlayer) return;
  await platform.setProperty(
    'demuxer-lavf-o',
    [
      'seg_max_retry=5',
      'allowed_extensions=ALL',
      'protocol_whitelist=[udp,rtp,tcp,tls,data,file,http,https,crypto]',
    ].join(','),
  );
  if (Platform.isWindows) {
    // Windows'ta paketle gelen yeni libmpv (windows/libmpv) media_kit'in
    // eski sürümüyle aynı davransın: ağ ffmpeg'in HTTP katmanından geçer,
    // sağlayıcıların bozuk sertifikaları yayını durdurmaz, önbellek
    // bellekte tutulur (yeni sürüm önbellek klasörü olmadan diske yazamıyor).
    for (final (name, value) in const [
      ('curl-enabled', 'no'),
      ('tls-verify', 'no'),
      ('cache-on-disk', 'no'),
    ]) {
      try {
        await platform.setProperty(name, value);
      } catch (e) {
        debugPrint('libmpv ayarı verilemedi ($name): $e');
      }
    }
  }
}

/// Oynatılacak adres. Windows'taki yeni libmpv, yönlendirilen HLS
/// listelerinin göreli alt adreslerini ilk adrese göre çözüyor (ör. Pluto
/// TV'nin jmp2.uk bağlantıları 404 veriyor). Bu yüzden `.m3u8` adreslerinin
/// yönlendirmesi önceden izlenir ve son adres verilir; hata olursa adres
/// olduğu gibi kalır.
Future<String> resolveStreamUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (!Platform.isWindows ||
      uri == null ||
      !uri.isScheme('http') && !uri.isScheme('https') ||
      !uri.path.toLowerCase().endsWith('.m3u8')) {
    return url;
  }
  final client = HttpClient()
    ..userAgent = 'libmpv'
    ..connectionTimeout = const Duration(seconds: 5)
    ..badCertificateCallback = (_, _, _) => true;
  try {
    final request = await client.getUrl(uri);
    final response = await request.close().timeout(const Duration(seconds: 5));
    var target = uri;
    for (final redirect in response.redirects) {
      target = target.resolveUri(redirect.location);
    }
    unawaited(response.drain<void>().catchError((_) {}));
    return target.toString();
  } catch (_) {
    return url;
  } finally {
    client.close(force: true);
  }
}

/// Bir oynatıcıda NVIDIA RTX Video Super Resolution: açıkken görüntü
/// D3D11 video işlemcisiyle monitörün yüksekliğine kadar büyütülür ve
/// sürücü bunu yapay zekâyla keskinleştirir. RTX olmayan kartlarda aynı
/// filtre sıradan bir ölçekleyici gibi çalışır.
class VideoSuperResolution {
  VideoSuperResolution(this.player) {
    _heightSub = player.stream.height.listen((h) {
      _videoHeight = h ?? 0;
      _apply();
    });
    rtxVsr.addListener(_apply);
  }

  final Player player;
  late final StreamSubscription<int?> _heightSub;
  int _videoHeight = 0;
  bool _enabled = true;
  String? _appliedFilter;

  /// Çoklu izlemede küçük karelerde kapatılır.
  set enabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    _apply();
  }

  /// Monitörün yüksekliğine ulaşmak için büyütme oranı (1–4, onda bire
  /// yuvarlı); boyut bilinmiyorsa null. Görüntü monitörden büyük ya da ona
  /// yakınsa oran 1'dir: sürücü o zaman yalnız sıkıştırma bozulmalarını
  /// temizler.
  @visibleForTesting
  static double? scaleFor(
      {required int videoHeight, required double displayHeight}) {
    if (videoHeight <= 0 || displayHeight <= 0) return null;
    final scale = (displayHeight / videoHeight).clamp(1.0, 4.0);
    return scale < 1.1 ? 1 : (scale * 10).round() / 10;
  }

  static double get _displayHeight {
    var height = 0.0;
    for (final display in PlatformDispatcher.instance.displays) {
      if (display.size.height > height) height = display.size.height;
    }
    return height;
  }

  Future<void> _apply() async {
    final platform = player.platform;
    if (!rtxVsrSupported || platform is! NativePlayer) return;
    final scale = rtxVsr.value && _enabled
        ? scaleFor(videoHeight: _videoHeight, displayHeight: _displayHeight)
        : null;
    final filter =
        scale == null ? '' : 'd3d11vpp=scale=$scale:scaling-mode=nvidia';
    if (filter == (_appliedFilter ?? '')) return;
    _appliedFilter = filter;
    try {
      // Filtre D3D11 karelerle çalışır; kopyalamalı çözücü bunu bozar.
      await platform.setProperty('hwdec', scale == null ? 'auto' : 'd3d11va');
      await platform.setProperty('vf', filter);
    } catch (e) {
      debugPrint('VSR ayarlanamadı: $e');
    }
  }

  Future<void> dispose() async {
    rtxVsr.removeListener(_apply);
    await _heightSub.cancel();
  }
}

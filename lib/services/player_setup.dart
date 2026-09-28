import 'package:media_kit/media_kit.dart' hide Playlist;

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
}

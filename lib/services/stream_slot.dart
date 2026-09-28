import 'dart:async';

import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:media_kit_video/media_kit_video.dart';

import '../models/playlist.dart';
import 'player_setup.dart';
import 'stall_watchdog.dart';

/// Ekrandaki tek oynatıcı: kendi libmpv örneği, kanalı ve takılma bekçisi.
/// Çoklu izlemede her kare bir [StreamSlot].
class StreamSlot {
  StreamSlot(Channel channel) : _channel = channel {
    watchdog = StallWatchdog(
      onRetry: (_) => _open(_channel),
      // Asılı bağlantı sağlayıcıdaki bağlantı hakkını tutmasın.
      onGiveUp: () {
        if (!_disposed) player.stop();
      },
    );
    // Yeniden açılışta konum sıfırlanır; yalnız ileri gidiş ilerlemedir.
    _positionSub = player.stream.position.listen((position) {
      if (position > _lastPosition) watchdog.progress();
      _lastPosition = position;
    });
    _stallTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_disposed) watchdog.check(playing: player.state.playing);
    });
    // Tek karede oynatıcının kendi ses çubuğuyla değişen düzey korunsun.
    _volumeSub = player.stream.volume.listen((v) {
      if (audio.output > 0 && v > 0) audio.volume = v;
    });
    play(channel);
  }

  final Player player = Player();
  late final VideoController controller = VideoController(player);
  late final Future<void> _configured = configurePlayer(player);

  /// Tam ekrana klavyeyle geçmek için.
  final videoKey = GlobalKey<VideoState>();
  late final StallWatchdog watchdog;
  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<double> _volumeSub;
  late final Timer _stallTimer;
  Duration _lastPosition = Duration.zero;
  bool _disposed = false;

  Channel _channel;
  Channel get channel => _channel;

  /// Bu karede bir önceki kanal; geri dönüş kısayolu için.
  Channel? _previous;
  Channel? get previous => _previous;

  /// Karenin sesi açık mı, düzeyi ve uygulama geneli sessizlik.
  final audio = SlotAudio();

  void play(Channel channel) {
    if (_disposed) return;
    if (!identical(channel, _channel)) _previous = _channel;
    _channel = channel;
    _lastPosition = Duration.zero;
    watchdog.start();
    _open(channel);
  }

  Future<void> _open(Channel channel) async {
    await _configured;
    // Beklerken kanal değiştiyse ya da kare kapandıysa açma.
    if (_disposed || !identical(channel, _channel)) return;
    player.open(Media(channel.url));
  }

  /// Çoklu izlemede her karenin sesi ayrı açılıp kapatılır.
  bool get audible => audio.audible;
  set audible(bool value) {
    if (value == audio.audible) return;
    audio.audible = value;
    _applyVolume();
  }

  /// Karenin ses düzeyi (0–100); kapalıyken de hatırlanır.
  double get volume => audio.volume;
  set volume(double value) {
    audio.volume = value.clamp(0, 100);
    _applyVolume();
  }

  /// Uygulama geneli sessizlik; tüm karelerde ortak tutulur.
  set muted(bool value) {
    if (value == audio.muted) return;
    audio.muted = value;
    _applyVolume();
  }

  void _applyVolume() {
    if (!_disposed) player.setVolume(audio.output);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _stallTimer.cancel();
    await _positionSub.cancel();
    await _volumeSub.cancel();
    watchdog.stop();
    watchdog.dispose();
    await player.dispose();
  }
}

/// Bir karenin ses durumu; oynatıcıya giden düzey [output].
class SlotAudio {
  bool audible = true;
  double volume = 100;
  bool muted = false;

  double get output => audible && !muted ? volume : 0;
}

/// Kare seçilince ses de ona geçsin mi: yalnız tek karede ses açıkken.
/// Birden fazla karede ses açıksa (ör. iki maç) ya da hepsi kapalıysa
/// seçim sesi değiştirmez.
bool audioFollowsSelection(Iterable<bool> audible) =>
    audible.where((a) => a).length == 1;

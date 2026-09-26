import 'dart:async';

import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:media_kit_video/media_kit_video.dart';

import '../models/playlist.dart';
import 'stall_watchdog.dart';

/// Ekrandaki tek oynatıcı: kendi libmpv örneği, kanalı ve takılma bekçisi.
/// Çoklu izlemede her kare bir [StreamSlot].
class StreamSlot {
  StreamSlot(Channel channel) : _channel = channel {
    watchdog = StallWatchdog(
      onRetry: (_) {
        if (!_disposed) player.open(Media(_channel.url));
      },
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
    play(channel);
  }

  final Player player = Player();
  late final VideoController controller = VideoController(player);

  /// Tam ekrana klavyeyle geçmek için.
  final videoKey = GlobalKey<VideoState>();
  late final StallWatchdog watchdog;
  late final StreamSubscription<Duration> _positionSub;
  late final Timer _stallTimer;
  Duration _lastPosition = Duration.zero;
  bool _disposed = false;

  Channel _channel;
  Channel get channel => _channel;

  /// Bu karede bir önceki kanal; geri dönüş kısayolu için.
  Channel? _previous;
  Channel? get previous => _previous;

  /// Sessize alınmadan önceki ses düzeyi; kullanıcı değiştirmiş olabilir.
  double _volume = 100;

  /// Çoklu izlemede sesi başka karede olduğu için.
  bool _backgrounded = false;

  /// Kullanıcı sessize aldığı için; tüm karelerde ortak tutulur.
  bool _muted = false;

  void play(Channel channel) {
    if (_disposed) return;
    if (!identical(channel, _channel)) _previous = _channel;
    _channel = channel;
    _lastPosition = Duration.zero;
    watchdog.start();
    player.open(Media(channel.url));
  }

  /// Çoklu izlemede ses yalnız seçili karede çalar.
  set backgrounded(bool value) {
    if (value == _backgrounded) return;
    _backgrounded = value;
    _applyVolume();
  }

  set muted(bool value) {
    if (value == _muted) return;
    _muted = value;
    _applyVolume();
  }

  void _applyVolume() {
    if (_disposed) return;
    if (_backgrounded || _muted) {
      final current = player.state.volume;
      if (current > 0) _volume = current;
      player.setVolume(0);
    } else {
      player.setVolume(_volume);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _stallTimer.cancel();
    await _positionSub.cancel();
    watchdog.stop();
    watchdog.dispose();
    await player.dispose();
  }
}

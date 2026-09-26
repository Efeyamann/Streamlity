import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:media_kit_video/media_kit_video.dart';

import '../models/playlist_source.dart';
import '../services/app_mute.dart';
import '../services/watch_progress_store.dart';
import 'track_menu.dart';

/// Film, dizi bölümü ya da geçmiş yayın oynatıcısı: ileri/geri sarılabilir,
/// [progressKey] verilirse kalınan yer saklanır.
class VodPlayerScreen extends StatefulWidget {
  const VodPlayerScreen({
    super.key,
    required this.title,
    required this.url,
    required this.source,
    this.subtitle,
    this.progressKey,
    this.progressMeta,
    this.start,
    this.progressStore,
  });

  final String title;
  final String? subtitle;
  final String url;
  final PlaylistSource source;
  final String? progressKey;

  /// Kayıtla saklanan ad ve poster; ana sayfadaki raf için.
  final WatchMeta? progressMeta;
  final Duration? start;
  final WatchProgressStore? progressStore;

  @override
  State<VodPlayerScreen> createState() => _VodPlayerScreenState();
}

class _VodPlayerScreenState extends State<VodPlayerScreen> {
  final _player = Player();
  late final _controller = VideoController(_player);
  late final Timer _saveTimer;
  late final AppLifecycleListener _lifecycle;
  bool _disposed = false;
  String? _error;
  late final StreamSubscription<String> _errorSub;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onExitRequested: () async {
      await _close();
      return AppExitResponse.exit;
    });
    _errorSub = _player.stream.error.listen((e) {
      // Oynatma hiç başlamadıysa göster; ortadaki geçici hatalar mpv'de
      // kendiliğinden toparlanabiliyor.
      if (mounted && _player.state.duration == Duration.zero) {
        setState(() => _error = e);
      }
    });
    _saveTimer = Timer.periodic(const Duration(seconds: 10), (_) => _save());
    appMuted.addListener(_applyMute);
    _applyMute();
    _player.open(Media(widget.url, start: widget.start));
  }

  /// Sessizken ses düzeyi 0; açılınca kullanıcının son düzeyine döner.
  double _volume = 100;

  void _applyMute() {
    if (_disposed) return;
    if (appMuted.value) {
      final current = _player.state.volume;
      if (current > 0) _volume = current;
      _player.setVolume(0);
    } else {
      _player.setVolume(_volume);
    }
    if (mounted) setState(() {});
  }

  void _save() {
    final key = widget.progressKey;
    final store = widget.progressStore;
    if (key == null || store == null || _disposed) return;
    final position = _player.state.position;
    if (position <= Duration.zero) return;
    store.write(
      widget.source,
      key,
      WatchProgress(position: position, duration: _player.state.duration),
      meta: widget.progressMeta,
    );
  }

  Future<void> _close() async {
    if (_disposed) return;
    _save();
    _disposed = true;
    _saveTimer.cancel();
    await _errorSub.cancel();
    await _player.dispose();
  }

  @override
  void dispose() {
    appMuted.removeListener(_applyMute);
    _lifecycle.dispose();
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyM): () =>
            appMuted.value = !appMuted.value,
      },
      child: Focus(autofocus: true, child: _scaffold(context, subtitle)),
    );
  }

  Widget _scaffold(BuildContext context, String? subtitle) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (subtitle != null)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          TrackMenus(player: _player),
          IconButton(
            tooltip: appMuted.value ? 'Sesi aç (M)' : 'Sessiz (M)',
            icon: Icon(appMuted.value ? Icons.volume_off : Icons.volume_up),
            onPressed: () => appMuted.value = !appMuted.value,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Video(controller: _controller),
          if (_error case final error?)
            ColoredBox(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 40, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 12),
                    const Text('Oynatılamadı',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

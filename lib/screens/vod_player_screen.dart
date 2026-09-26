import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:media_kit_video/media_kit_video.dart';

import '../models/playlist_source.dart';
import '../services/app_mute.dart';
import '../services/watch_progress_store.dart';
import '../ui/player_controls.dart';
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';
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

  /// Denetimlerle birlikte görünüp kaybolan üst şerit: geri, başlık,
  /// parça menüleri ve ses.
  List<Widget> _topBar(BuildContext context, String? subtitle,
      {required bool back}) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return [
      if (back)
        IconButton(
          tooltip: 'Geri',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      const SizedBox(width: Space.xs),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(color: c.fg)),
            if (subtitle != null)
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: c.fg.withValues(alpha: 0.75))),
          ],
        ),
      ),
      TrackMenus(player: _player),
      ValueListenableBuilder(
        valueListenable: appMuted,
        builder: (context, muted, _) => IconButton(
          tooltip: muted ? 'Sesi aç (M)' : 'Sessiz (M)',
          icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
          onPressed: () => appMuted.value = !muted,
        ),
      ),
    ];
  }

  Widget _scaffold(BuildContext context, String? subtitle) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MaterialDesktopVideoControlsTheme(
            normal: vodControls.copyWith(
              visibleOnMount: true,
              hideMouseOnControlsRemoval: true,
              topButtonBar: _topBar(context, subtitle, back: true),
            ),
            // Tam ekranda geri yerine denetimlerdeki çıkış düğmesi kullanılır.
            fullscreen: vodControls.copyWith(
              hideMouseOnControlsRemoval: true,
              topButtonBar: _topBar(context, subtitle, back: false),
            ),
            child: Video(controller: _controller),
          ),
          if (_error case final error?)
            ColoredBox(
              color: c.scrim,
              child: EmptyState(
                icon: Icons.error_outline,
                tone: c.danger,
                title: 'Oynatılamadı',
                message: error,
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Geri dön'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:media_kit_video/media_kit_video.dart';

import '../models/epg.dart';
import '../models/playlist.dart';
import '../models/playlist_source.dart';
import '../models/saved_source.dart';
import '../services/epg_loader.dart';
import '../services/favorites_store.dart';
import '../services/playlist_loader.dart';
import '../services/stall_watchdog.dart';
import 'sources_screen.dart' show formatDate;

/// Bir listenin kanalları, yayın akışı ve oynatıcı. Geri gidilince oynatıcı
/// kapanır.
class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({
    super.key,
    required this.saved,
    required this.onLoaded,
  });

  final SavedSource saved;

  /// Liste yüklenince; ana sayfadaki kartın özet bilgileri için.
  final void Function(int channelCount, DateTime? expiresAt) onLoaded;

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late final Player _player = Player();
  late final VideoController _videoController = VideoController(_player);

  PlaylistSource get _source => widget.saved.source;
  Playlist? _playlist;
  bool _loading = true;
  String? _error;

  Epg? _epg;
  bool _epgLoading = false;
  String? _epgError;

  /// Akışın en son sağlayıcıyla karşılaştırıldığı an; uzun açık kalan
  /// uygulamada yenilemek için.
  DateTime? _epgCheckedAt;

  /// Yayın akışındaki "şu an" için; periyodik olarak ilerletilir.
  DateTime _now = DateTime.now();
  late final Timer _clock;

  final _favoritesStore = FavoritesStore();
  Set<String> _favorites = {};

  /// Grup listesindeki "Favoriler" girdisi; gerçek grup adlarıyla çakışmaz.
  static const _favoritesGroup = '\u0000favoriler';

  late final StallWatchdog _watchdog = StallWatchdog(
    onRetry: (_) {
      final channel = _current;
      if (channel != null && !_playerDisposed) {
        _player.open(Media(channel.url));
      }
    },
    // Asılı bağlantı sağlayıcıdaki tek bağlantı hakkını tutmasın.
    onGiveUp: () {
      if (!_playerDisposed) _player.stop();
    },
  );
  late final StreamSubscription<Duration> _positionSub;
  late final Timer _stallTimer;
  Duration _lastPosition = Duration.zero;

  /// null: tüm kanallar; [_favoritesGroup]: favoriler.
  String? _group;
  String _query = '';
  Channel? _current;

  late final AppLifecycleListener _lifecycle;
  bool _playerDisposed = false;

  @override
  void initState() {
    super.initState();
    // Pencere kapanırken widget'lar dispose edilmez; oynatıcıyı burada
    // kapatmazsak libmpv süreç sonlanana kadar ses çalmaya devam eder.
    _lifecycle = AppLifecycleListener(
      onExitRequested: () async {
        await _disposePlayer();
        return AppExitResponse.exit;
      },
    );
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_epg != null) setState(() => _now = DateTime.now());
      final playlist = _playlist, checked = _epgCheckedAt;
      if (playlist != null &&
          !_epgLoading &&
          checked != null &&
          DateTime.now().difference(checked) > epgMaxAge) {
        _loadEpg(playlist);
      }
    });
    // Yeniden açılışta konum sıfırlanır; yalnız ileri gidiş ilerlemedir.
    _positionSub = _player.stream.position.listen((position) {
      if (position > _lastPosition) _watchdog.progress();
      _lastPosition = position;
    });
    _stallTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_playerDisposed) _watchdog.check(playing: _player.state.playing);
    });
    _load();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _clock.cancel();
    _stallTimer.cancel();
    _positionSub.cancel();
    _disposePlayer();
    _watchdog.dispose();
    super.dispose();
  }

  Future<void> _disposePlayer() async {
    if (_playerDisposed) return;
    _playerDisposed = true;
    _watchdog.stop();
    await _player.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final playlist = await loadSource(_source);
      final favorites = await _favoritesStore.read(_source);
      if (!mounted) return;
      setState(() {
        _playlist = playlist;
        _favorites = favorites;
        _group = null;
        _query = '';
      });
      widget.onLoaded(playlist.channelCount, playlist.expiresAt);
      _loadEpg(playlist);
    } on PlaylistException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Yayın akışını arka planda yükler; kanal listesi beklemez. Diskte kayıt
  /// varsa önce o gösterilir, gerekirse güncel hali ardından gelir. Yenileme
  /// sırasında eldeki akış ekranda kalır.
  Future<void> _loadEpg(Playlist playlist) async {
    setState(() {
      _epgError = null;
      _epgLoading = true;
    });
    // Yükleme sürerken kaynak değiştiyse sonucu at.
    bool stale() => !mounted || !identical(_playlist, playlist);
    try {
      await for (final epg in loadEpg(playlist)) {
        if (stale()) return;
        setState(() {
          _epg = epg;
          _now = DateTime.now();
        });
      }
    } catch (e) {
      if (stale()) return;
      setState(() => _epgError = '$e');
    } finally {
      if (!stale()) {
        setState(() {
          _epgLoading = false;
          _epgCheckedAt = DateTime.now();
        });
      }
    }
  }

  void _play(Channel channel) {
    setState(() => _current = channel);
    _lastPosition = Duration.zero;
    _watchdog.start();
    _player.open(Media(channel.url));
  }

  void _toggleFavorite(Channel channel) {
    final source = _source;
    setState(() {
      _favorites = {..._favorites};
      if (!_favorites.remove(channel.key)) _favorites.add(channel.key);
    });
    _favoritesStore.write(source, _favorites);
  }

  List<Channel> _visibleChannels(Playlist playlist) {
    final query = searchKey(_query);
    final favoritesOnly = _group == _favoritesGroup;
    return playlist.channels.where((c) {
      if (favoritesOnly) {
        if (!_favorites.contains(c.key)) return false;
      } else if (_group != null && (c.group ?? Playlist.ungrouped) != _group) {
        return false;
      }
      // Aramada başlık satırları anlamsız.
      return query.isEmpty ||
          (!c.isSeparator && searchKey(c.name).contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _playlist;
    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.saved.name)),
        body: Center(
          child: _loading || _error == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Kanal listesi yükleniyor…'),
                  ],
                )
              : _LoadError(message: _error!, onRetry: _load),
        ),
      );
    }

    final channels = _visibleChannels(playlist);
    final expiresAt = playlist.expiresAt;
    final onAir = _epg?.current(_current?.tvgId, _now);
    return Scaffold(
      appBar: AppBar(
        title: Text(_current?.name ?? widget.saved.name),
        actions: [
          if (_epgLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Yayın akışı güncelleniyor'),
                ],
              ),
            )
          else if (_epgError != null)
            Tooltip(
              message: _epgError!,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.event_busy),
              ),
            ),
          if (expiresAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Bitiş: ${formatDate(expiresAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: _GroupList(
              groups: playlist.groups,
              selected: _group,
              total: playlist.channelCount,
              favoritesKey: _favoritesGroup,
              favoritesCount: _favorites.length,
              onSelected: (g) => setState(() => _group = g),
            ),
          ),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 340,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Kanal ara',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: channels.length,
                    itemExtentBuilder: (i, _) =>
                        i < channels.length && channels[i].isSeparator ? 40 : 64,
                    itemBuilder: (context, i) {
                      final channel = channels[i];
                      if (channel.isSeparator) {
                        return _SeparatorTile(label: channel.separatorLabel!);
                      }
                      final favorite = _favorites.contains(channel.key);
                      final programme = _epg?.current(channel.tvgId, _now);
                      return ListTile(
                        leading: _ChannelLogo(url: channel.logo),
                        title: Text(
                          channel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: programme == null
                            ? null
                            : Text(
                                programme.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        trailing: IconButton(
                          tooltip: favorite
                              ? 'Favorilerden çıkar'
                              : 'Favorilere ekle',
                          icon: Icon(favorite ? Icons.star : Icons.star_border),
                          onPressed: () => _toggleFavorite(channel),
                        ),
                        selected: identical(channel, _current),
                        onTap: () => _play(channel),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _current == null
                ? const Center(child: Text('Oynatmak için bir kanal seç'))
                : Column(
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Video(controller: _videoController),
                            ListenableBuilder(
                              listenable: _watchdog,
                              builder: (context, _) => _StallOverlay(
                                watchdog: _watchdog,
                                onRetry: () => _play(_current!),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onAir != null)
                        _NowNext(
                          current: onAir,
                          next: _epg!.next(_current!.tvgId, _now),
                          now: _now,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupList extends StatefulWidget {
  const _GroupList({
    required this.groups,
    required this.selected,
    required this.total,
    required this.favoritesKey,
    required this.favoritesCount,
    required this.onSelected,
  });

  final List<String> groups;
  final String? selected;
  final int total;
  final String favoritesKey;
  final int favoritesCount;
  final ValueChanged<String?> onSelected;

  @override
  State<_GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<_GroupList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = searchKey(_query.trim());
    final groups = query.isEmpty
        ? widget.groups
        : widget.groups.where((g) => searchKey(g).contains(query)).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Kategori ara',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            // Aramada "Tümü" ve "Favoriler" gizlenir.
            itemCount: query.isEmpty ? groups.length + 2 : groups.length,
            itemBuilder: (context, i) {
              if (query.isNotEmpty) i += 2;
              final group = switch (i) {
                0 => null,
                1 => widget.favoritesKey,
                _ => groups[i - 2],
              };
              return ListTile(
                dense: true,
                leading: i == 1 ? const Icon(Icons.star, size: 18) : null,
                minLeadingWidth: 0,
                title: Text(
                  switch (i) {
                    0 => 'Tümü (${widget.total})',
                    1 => 'Favoriler (${widget.favoritesCount})',
                    _ => group!,
                  },
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: group == widget.selected,
                onTap: () => widget.onSelected(group),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChannelLogo extends StatelessWidget {
  const _ChannelLogo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.live_tv);
    final url = this.url;
    return SizedBox.square(
      dimension: 36,
      child: url == null
          ? fallback
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// Oynayan kanalın şu anki ve sıradaki programı.
class _NowNext extends StatelessWidget {
  const _NowNext({required this.current, required this.next, required this.now});

  final Programme current;
  final Programme? next;
  final DateTime now;

  static String _time(DateTime t) {
    final local = t.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final next = this.next;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${_time(current.start)}–${_time(current.stop)}',
                  style: muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  current.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: current.progress(now)),
          if (current.description != null) ...[
            const SizedBox(height: 8),
            Text(
              current.description!,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (next != null) ...[
            const SizedBox(height: 8),
            Text(
              'Sonra ${_time(next.start)}  ${next.title}',
              style: muted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Sağlayıcının `#### NEWS ####` gibi başlık satırları.
class _SeparatorTile extends StatelessWidget {
  const _SeparatorTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

/// Yayın durunca yeniden bağlanma durumu ya da vazgeçildiyse hata.
class _StallOverlay extends StatelessWidget {
  const _StallOverlay({required this.watchdog, required this.onRetry});

  final StallWatchdog watchdog;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (watchdog.status) {
      case StallStatus.ok:
        return const SizedBox.shrink();
      case StallStatus.reconnecting:
        return IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Yayın gelmiyor, yeniden bağlanılıyor '
                        '(${watchdog.attempt}/${watchdog.maxRetries})',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case StallStatus.failed:
        return ColoredBox(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.signal_wifi_bad,
                    size: 40, color: theme.colorScheme.error),
                const SizedBox(height: 12),
                const Text(
                  'Kanal açılamadı',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sağlayıcı yayın göndermiyor ya da bağlantı sınırı dolu.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeniden dene'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text('Liste açılamadı', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Listelere dön'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

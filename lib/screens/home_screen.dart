import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:media_kit_video/media_kit_video.dart';

import '../models/epg.dart';
import '../models/playlist.dart';
import '../models/playlist_source.dart';
import '../services/epg_loader.dart';
import '../services/playlist_loader.dart';
import '../services/source_store.dart';
import 'source_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Player _player = Player();
  late final VideoController _videoController = VideoController(_player);

  final _store = const SourceStore();
  PlaylistSource? _source;
  Playlist? _playlist;
  bool _loading = true;
  String? _error;

  Epg? _epg;
  bool _epgLoading = false;
  String? _epgError;

  /// Yayın akışındaki "şu an" için; periyodik olarak ilerletilir.
  DateTime _now = DateTime.now();
  late final Timer _clock;

  /// null: tüm kanallar.
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
    });
    _restore();
  }

  Future<void> _restore() async {
    final saved = await _store.read();
    if (saved == null) {
      setState(() => _loading = false);
    } else {
      await _load(saved);
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _clock.cancel();
    _disposePlayer();
    super.dispose();
  }

  Future<void> _disposePlayer() async {
    if (_playerDisposed) return;
    _playerDisposed = true;
    await _player.dispose();
  }

  Future<void> _load(PlaylistSource source) async {
    setState(() {
      _source = source;
      _loading = true;
      _error = null;
    });
    try {
      final playlist = await loadSource(source);
      await _store.write(source);
      if (!mounted) return;
      setState(() {
        _playlist = playlist;
        _group = null;
        _query = '';
      });
      _loadEpg(playlist);
    } on PlaylistException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Yayın akışını arka planda yükler; kanal listesi beklemez.
  Future<void> _loadEpg(Playlist playlist) async {
    setState(() {
      _epg = null;
      _epgError = null;
      _epgLoading = true;
    });
    // Yükleme sürerken kaynak değiştiyse sonucu at.
    bool stale() => !mounted || !identical(_playlist, playlist);
    try {
      final epg = await loadEpg(playlist);
      if (stale()) return;
      setState(() {
        _epg = epg;
        _now = DateTime.now();
      });
    } catch (e) {
      if (stale()) return;
      setState(() => _epgError = '$e');
    } finally {
      if (!stale()) setState(() => _epgLoading = false);
    }
  }

  /// Oynatmayı durdurur ve kayıtlı kaynağı siler; açılışta giriş ekranı gelir.
  Future<void> _signOut() async {
    _player.stop();
    await _store.clear();
    setState(() {
      _playlist = null;
      _current = null;
      _error = null;
      _epg = null;
      _epgError = null;
      _epgLoading = false;
    });
  }

  void _play(Channel channel) {
    setState(() => _current = channel);
    _player.open(Media(channel.url));
  }

  List<Channel> _visibleChannels(Playlist playlist) {
    final query = _query.toLowerCase();
    return playlist.channels.where((c) {
      if (_group != null && (c.group ?? Playlist.ungrouped) != _group) {
        return false;
      }
      return query.isEmpty || c.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _playlist;
    if (playlist == null) {
      return Scaffold(
        body: SourceForm(
          // Form alanları yalnız ilk kurulumda doldurulur; açılışta kayıt
          // okunduktan sonra formu o kaynakla yeniden kur.
          key: ObjectKey(_source),
          initial: _source,
          loading: _loading,
          error: _error,
          onSubmit: _load,
        ),
      );
    }

    final channels = _visibleChannels(playlist);
    final expiresAt = playlist.expiresAt;
    final onAir = _epg?.current(_current?.tvgId, _now);
    return Scaffold(
      appBar: AppBar(
        title: Text(_current?.name ?? 'Streamlity'),
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
                  Text('Yayın akışı yükleniyor'),
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
                'Bitiş: ${expiresAt.day.toString().padLeft(2, '0')}.'
                '${expiresAt.month.toString().padLeft(2, '0')}.'
                '${expiresAt.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          IconButton(
            tooltip: 'Çıkış yap',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: _GroupList(
              groups: playlist.groups,
              selected: _group,
              total: playlist.channels.length,
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
                    itemExtent: 64,
                    itemBuilder: (context, i) {
                      final channel = channels[i];
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
                      Expanded(child: Video(controller: _videoController)),
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

class _GroupList extends StatelessWidget {
  const _GroupList({
    required this.groups,
    required this.selected,
    required this.total,
    required this.onSelected,
  });

  final List<String> groups;
  final String? selected;
  final int total;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groups.length + 1,
      itemBuilder: (context, i) {
        final group = i == 0 ? null : groups[i - 1];
        return ListTile(
          dense: true,
          title: Text(
            group ?? 'Tümü ($total)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          selected: group == selected,
          onTap: () => onSelected(group),
        );
      },
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

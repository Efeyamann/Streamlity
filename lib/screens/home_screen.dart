import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:media_kit_video/media_kit_video.dart';

import '../models/playlist.dart';
import '../services/playlist_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Player _player = Player();
  late final VideoController _videoController = VideoController(_player);

  Playlist? _playlist;
  bool _loading = false;
  String? _error;

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
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _disposePlayer();
    super.dispose();
  }

  Future<void> _disposePlayer() async {
    if (_playerDisposed) return;
    _playerDisposed = true;
    await _player.dispose();
  }

  Future<void> _load(String source) async {
    source = source.trim();
    if (source.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final playlist = await loadPlaylist(source);
      setState(() {
        _playlist = playlist;
        _group = null;
        _query = '';
      });
    } on PlaylistException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _closePlaylist() {
    _player.stop();
    setState(() {
      _playlist = null;
      _current = null;
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
        body: _PlaylistSourceForm(
          loading: _loading,
          error: _error,
          onSubmit: _load,
        ),
      );
    }

    final channels = _visibleChannels(playlist);
    return Scaffold(
      appBar: AppBar(
        title: Text(_current?.name ?? 'Streamlity'),
        actions: [
          IconButton(
            tooltip: 'Listeyi kapat',
            icon: const Icon(Icons.playlist_remove),
            onPressed: _closePlaylist,
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
                    itemExtent: 56,
                    itemBuilder: (context, i) {
                      final channel = channels[i];
                      return ListTile(
                        leading: _ChannelLogo(url: channel.logo),
                        title: Text(
                          channel.name,
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
                : Video(controller: _videoController),
          ),
        ],
      ),
    );
  }
}

class _PlaylistSourceForm extends StatefulWidget {
  const _PlaylistSourceForm({
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  final bool loading;
  final String? error;
  final ValueChanged<String> onSubmit;

  @override
  State<_PlaylistSourceForm> createState() => _PlaylistSourceFormState();
}

class _PlaylistSourceFormState extends State<_PlaylistSourceForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Streamlity',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                enabled: !widget.loading,
                decoration: InputDecoration(
                  labelText: 'M3U listesi (URL veya dosya yolu)',
                  border: const OutlineInputBorder(),
                  errorText: widget.error,
                  errorMaxLines: 3,
                ),
                onSubmitted: widget.onSubmit,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: widget.loading
                    ? null
                    : () => widget.onSubmit(_controller.text),
                child: widget.loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Yükle'),
              ),
            ],
          ),
        ),
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

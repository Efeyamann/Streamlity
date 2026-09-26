import 'package:flutter/material.dart';

import '../models/playlist.dart' show searchKey;
import '../models/playlist_source.dart';
import '../models/vod.dart';
import '../services/favorites_store.dart';
import '../services/watch_progress_store.dart';
import '../services/xtream_vod.dart';
import 'vod_player_screen.dart';

enum _Sort { provider, name, rating, year }

/// Film ya da dizi kataloğu: solda kategoriler, ortada poster ızgarası.
class VodBrowser extends StatefulWidget {
  const VodBrowser({
    super.key,
    required this.source,
    required this.kind,
    required this.catalog,
    required this.onRetry,
    required this.progressStore,
  });

  final XtreamSource source;
  final VodKind kind;
  final Future<VodCatalog> catalog;
  final VoidCallback onRetry;
  final WatchProgressStore progressStore;

  @override
  State<VodBrowser> createState() => _VodBrowserState();
}

class _VodBrowserState extends State<VodBrowser> {
  /// null: tümü; [_continueKey]: izlemeye devam et.
  String? _category;
  static const _continueKey = '\u0000devam';
  String _categoryQuery = '';
  String _query = '';
  _Sort _sort = _Sort.provider;
  Map<String, WatchProgress> _progress = {};

  /// Favori kategoriler (film ve dizi ortak dosyada, türe göre önekli).
  final _groupsStore = FavoritesStore.vodGroups();
  List<String> _favoriteGroups = [];

  bool get _movies => widget.kind == VodKind.movie;

  String _groupKey(String categoryId) =>
      '${_movies ? 'm' : 's'}:$categoryId';

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _groupsStore.readList(widget.source).then((groups) {
      if (mounted) setState(() => _favoriteGroups = groups);
    });
  }

  void _toggleFavoriteGroup(String categoryId) {
    final key = _groupKey(categoryId);
    setState(() {
      _favoriteGroups = _favoriteGroups.contains(key)
          ? [
              for (final g in _favoriteGroups)
                if (g != key) g,
            ]
          : [..._favoriteGroups, key];
    });
    _groupsStore.writeList(widget.source, _favoriteGroups);
  }

  Future<void> _loadProgress() async {
    final progress = await widget.progressStore.read(widget.source);
    if (mounted) setState(() => _progress = progress);
  }

  List<VodItem> _visible(VodCatalog catalog) {
    final query = searchKey(_query.trim());
    final items = catalog.items.where((i) {
      if (_category == _continueKey) {
        if (!(_progress[i.key]?.resumable ?? false)) return false;
      } else if (_category != null && i.categoryId != _category) {
        return false;
      }
      return query.isEmpty || searchKey(i.name).contains(query);
    }).toList();
    switch (_sort) {
      case _Sort.provider:
        break;
      case _Sort.name:
        items.sort((a, b) => searchKey(a.name).compareTo(searchKey(b.name)));
      case _Sort.rating:
        items.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case _Sort.year:
        items.sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));
    }
    return items;
  }

  Future<void> _open(VodItem item) async {
    if (_movies) {
      final choice = await showDialog<_PlayChoice>(
        context: context,
        builder: (_) => _MovieDialog(
          source: widget.source,
          movie: item,
          progress: _progress[item.key],
        ),
      );
      if (choice == null || !mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => VodPlayerScreen(
          title: item.name,
          url: movieUrl(widget.source, item),
          source: widget.source,
          progressKey: item.key,
          progressStore: widget.progressStore,
          start: choice.start,
        ),
      ));
    } else {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => _SeriesScreen(
          source: widget.source,
          series: item,
          progressStore: widget.progressStore,
        ),
      ));
    }
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VodCatalog>(
      future: widget.catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 40, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text('${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar dene'),
                ),
              ],
            ),
          );
        }
        final catalog = snapshot.data;
        if (catalog == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_movies ? 'Filmler yükleniyor…' : 'Diziler yükleniyor…'),
              ],
            ),
          );
        }
        return Row(
          children: [
            SizedBox(width: 220, child: _categories(catalog)),
            const VerticalDivider(width: 1),
            Expanded(child: _grid(catalog)),
          ],
        );
      },
    );
  }

  Widget _categories(VodCatalog catalog) {
    final query = searchKey(_categoryQuery.trim());
    final cats = query.isEmpty
        ? catalog.categories
        : catalog.categories
            .where((c) => searchKey(c.name).contains(query))
            .toList();
    final resumable = _movies
        ? catalog.items.where((i) => _progress[i.key]?.resumable ?? false).length
        : 0;
    final favorites = {..._favoriteGroups};
    final byId = {for (final c in catalog.categories) c.id: c};
    final prefix = _groupKey('');
    final pinned = query.isEmpty
        ? [
            for (final k in _favoriteGroups)
              if (k.startsWith(prefix)) ?byId[k.substring(prefix.length)],
          ]
        : const <VodCategory>[];
    // (anahtar, etiket, ikon, başlık mı, yıldızlı kategori mi)
    final rows = <(String?, String, IconData?, bool, bool)>[
      if (query.isEmpty)
        (null, 'Tümü (${catalog.items.length})', null, false, false),
      if (query.isEmpty && resumable > 0)
        (_continueKey, 'İzlemeye devam et ($resumable)', Icons.history, false,
            false),
      if (pinned.isNotEmpty) ...[
        (null, 'Favori paketler', null, true, false),
        for (final c in pinned) (c.id, c.name, null, false, true),
        (null, 'Tüm kategoriler', null, true, false),
      ],
      for (final c in cats) (c.id, c.name, null, false, true),
    ];
    final theme = Theme.of(context);
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
            onChanged: (v) => setState(() => _categoryQuery = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final (key, label, icon, header, category) = rows[i];
              if (header) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                );
              }
              final favorite =
                  category && favorites.contains(_groupKey(key!));
              return ListTile(
                dense: true,
                leading: icon == null ? null : Icon(icon, size: 18),
                minLeadingWidth: 0,
                contentPadding: const EdgeInsets.only(left: 16, right: 4),
                title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: category
                    ? IconButton(
                        tooltip: favorite
                            ? 'Favori paketlerden çıkar'
                            : 'Favori paketlere ekle',
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(favorite ? Icons.star : Icons.star_border),
                        color: favorite ? theme.colorScheme.primary : null,
                        onPressed: () => _toggleFavoriteGroup(key!),
                      )
                    : null,
                selected: key == _category,
                onTap: () => setState(() => _category = key),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _grid(VodCatalog catalog) {
    final items = _visible(catalog);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: _movies ? 'Film ara' : 'Dizi ara',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<_Sort>(
                tooltip: 'Sırala',
                icon: const Icon(Icons.sort),
                initialValue: _sort,
                onSelected: (s) => setState(() => _sort = s),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: _Sort.provider, child: Text('Sağlayıcı sırası')),
                  PopupMenuItem(value: _Sort.name, child: Text('Ada göre')),
                  PopupMenuItem(value: _Sort.rating, child: Text('Puana göre')),
                  PopupMenuItem(value: _Sort.year, child: Text('Yıla göre')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Eşleşen içerik yok'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 170,
                    mainAxisExtent: 300,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _PosterCard(
                    item: items[i],
                    progress: _progress[items[i].key],
                    onTap: () => _open(items[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.item, required this.onTap, this.progress});

  final VodItem item;
  final WatchProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = [
      if (item.year case final y?) '$y',
      if (item.rating case final r?) '★ ${r.toStringAsFixed(1)}',
    ].join('  ');
    final progress = this.progress;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Poster(url: item.poster),
                  if (progress != null && progress.resumable)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                          value: progress.fraction, minHeight: 4),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium),
          if (meta.isNotEmpty)
            Text(meta,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.surfaceContainerHigh;
    final fallback = ColoredBox(
      color: background,
      child: const Center(child: Icon(Icons.movie_outlined, size: 36)),
    );
    final url = this.url;
    if (url == null) return fallback;
    // Büyük katalogda bellek için küçük çöz.
    return Image.network(
      url,
      fit: BoxFit.cover,
      cacheWidth: 340,
      // Yavaş ya da yanıt vermeyen sunucuda kart boş görünmesin.
      frameBuilder: (_, child, frame, sync) => frame == null && !sync
          ? ColoredBox(color: background)
          : child,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

String formatDuration(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60;
  return h > 0 ? '$h sa $m dk' : '$m dk';
}

String formatPosition(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Film penceresinden dönen seçim; [start] null ise baştan.
typedef _PlayChoice = ({Duration? start});

class _MovieDialog extends StatefulWidget {
  const _MovieDialog({
    required this.source,
    required this.movie,
    required this.progress,
  });

  final XtreamSource source;
  final VodItem movie;
  final WatchProgress? progress;

  @override
  State<_MovieDialog> createState() => _MovieDialogState();
}

class _MovieDialogState extends State<_MovieDialog> {
  late final Future<VodDetails> _details =
      loadMovieDetails(widget.source, widget.movie.id);

  VodItem get movie => widget.movie;

  void _play(BuildContext context, {Duration? start}) =>
      Navigator.of(context).pop<_PlayChoice>((start: start));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.progress;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 520),
        child: FutureBuilder<VodDetails>(
          future: _details,
          builder: (context, snapshot) {
            final d = snapshot.data;
            final facts = [
              if (movie.year case final y?) '$y',
              if (d?.duration case final t?) formatDuration(t),
              if (movie.rating case final r?) '★ ${r.toStringAsFixed(1)}',
              ?d?.genre,
            ];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 240, child: _Poster(url: movie.poster)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(movie.name, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text(facts.join('  ·  '),
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: snapshot.connectionState !=
                                  ConnectionState.done
                              ? const Align(
                                  alignment: Alignment.topLeft,
                                  child: SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(d?.plot ?? movie.plot ??
                                          'Açıklama yok.'),
                                      if (d?.director case final dir?) ...[
                                        const SizedBox(height: 12),
                                        Text('Yönetmen: $dir',
                                            style: theme.textTheme.bodySmall),
                                      ],
                                      if (d?.cast case final cast?) ...[
                                        const SizedBox(height: 4),
                                        Text('Oyuncular: $cast',
                                            style: theme.textTheme.bodySmall),
                                      ],
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (progress != null && progress.resumable) ...[
                              FilledButton.icon(
                                onPressed: () =>
                                    _play(context, start: progress.position),
                                icon: const Icon(Icons.play_arrow),
                                label: Text('Devam et '
                                    '(${formatPosition(progress.position)})'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _play(context),
                                icon: const Icon(Icons.replay),
                                label: const Text('Baştan başla'),
                              ),
                            ] else
                              FilledButton.icon(
                                onPressed: () => _play(context),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Oynat'),
                              ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Kapat'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SeriesScreen extends StatefulWidget {
  const _SeriesScreen({
    required this.source,
    required this.series,
    required this.progressStore,
  });

  final XtreamSource source;
  final VodItem series;
  final WatchProgressStore progressStore;

  @override
  State<_SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<_SeriesScreen> {
  late Future<SeriesDetails> _details =
      loadSeriesDetails(widget.source, widget.series.id);
  Map<String, WatchProgress> _progress = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await widget.progressStore.read(widget.source);
    if (mounted) setState(() => _progress = progress);
  }

  Future<void> _play(Episode e) async {
    final progress = _progress[e.key];
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => VodPlayerScreen(
        title: widget.series.name,
        subtitle: '${e.season}. sezon ${e.number}. bölüm · ${e.title}',
        url: episodeUrl(widget.source, e),
        source: widget.source,
        progressKey: e.key,
        progressStore: widget.progressStore,
        start: progress != null && progress.resumable ? progress.position : null,
      ),
    ));
    _loadProgress();
  }

  /// İlk izlenmemiş (ya da yarım kalan) bölüm.
  Episode? _nextUp(SeriesDetails d) {
    Episode? lastWatched;
    for (final list in d.seasons.values) {
      for (final e in list) {
        final p = _progress[e.key];
        if (p == null) continue;
        // Az izlenmiş bölüm de sıradakidir; yalnız bitenler atlanır.
        if (!p.finished) return e;
        lastWatched = e;
      }
    }
    if (lastWatched == null) return null;
    final all = [for (final l in d.seasons.values) ...l];
    final i = all.indexOf(lastWatched);
    return i + 1 < all.length ? all[i + 1] : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.series.name)),
      body: FutureBuilder<SeriesDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.error}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() => _details =
                        loadSeriesDetails(widget.source, widget.series.id)),
                    child: const Text('Tekrar dene'),
                  ),
                ],
              ),
            );
          }
          final d = snapshot.data;
          if (d == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (d.seasons.isEmpty) {
            return const Center(child: Text('Bu dizide bölüm yok'));
          }
          final next = _nextUp(d);
          final facts = [
            if (widget.series.year case final y?) '$y',
            if (widget.series.rating case final r?) '★ ${r.toStringAsFixed(1)}',
            ?d.info.genre,
            '${d.seasons.length} sezon',
          ];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _Poster(url: widget.series.poster),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(facts.join('  ·  '),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    if (next != null) ...[
                      FilledButton.icon(
                        onPressed: () => _play(next),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                            'S${next.season} B${next.number} '
                            '${_progress[next.key]?.resumable ?? false ? 'devam et' : 'oynat'}'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(d.info.plot ?? widget.series.plot ?? ''),
                    if (d.info.cast case final cast?) ...[
                      const SizedBox(height: 12),
                      Text('Oyuncular: $cast', style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: DefaultTabController(
                  length: d.seasons.length,
                  initialIndex: next == null
                      ? 0
                      : d.seasons.keys.toList().indexOf(next.season),
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          for (final s in d.seasons.keys)
                            Tab(text: '$s. sezon'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            for (final list in d.seasons.values)
                              ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: list.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) =>
                                    _episodeTile(list[i]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _episodeTile(Episode e) {
    final theme = Theme.of(context);
    final p = _progress[e.key];
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: SizedBox(
        width: 40,
        child: Text('${e.number}',
            textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
      ),
      title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (e.plot != null)
            Text(e.plot!, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (p != null && !p.finished && p.resumable)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(value: p.fraction, minHeight: 3),
            ),
        ],
      ),
      trailing: p != null && p.finished
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : e.duration == null
              ? null
              : Text(formatDuration(e.duration!),
                  style: theme.textTheme.bodySmall),
      onTap: () => _play(e),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/playlist.dart' show searchKey;
import '../models/playlist_source.dart';
import '../models/vod.dart';
import '../services/favorites_store.dart';
import '../services/watch_progress_store.dart';
import '../services/xtream_vod.dart';
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';
import '../ui/widgets/poster.dart';
import 'vod_player_screen.dart';

enum _Sort {
  provider('Sağlayıcı sırası'),
  name('Ada göre'),
  rating('Puana göre'),
  year('Yıla göre');

  const _Sort(this.label);
  final String label;
}

/// Poster ızgarasının ölçüleri; iskelet de aynısını kullanır.
const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 176,
  mainAxisExtent: 318,
  crossAxisSpacing: Space.md,
  mainAxisSpacing: Space.lg,
);

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

  /// Kategori başına öğe sayısı; katalog değişmedikçe bir kez sayılır.
  Map<String, int> _counts = const {};
  VodCatalog? _countedCatalog;

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

  Map<String, int> _countsFor(VodCatalog catalog) {
    if (!identical(catalog, _countedCatalog)) {
      final counts = <String, int>{};
      for (final i in catalog.items) {
        final id = i.categoryId;
        if (id != null) counts[id] = (counts[id] ?? 0) + 1;
      }
      _counts = counts;
      _countedCatalog = catalog;
    }
    return _counts;
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
    await openVodItem(
      context,
      source: widget.source,
      item: item,
      progressStore: widget.progressStore,
      progress: _progress[item.key],
    );
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VodCatalog>(
      future: widget.catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.cloud_off_outlined,
            tone: AppColors.of(context).danger,
            title: _movies ? 'Filmler alınamadı' : 'Diziler alınamadı',
            message: '${snapshot.error}',
            actions: [
              FilledButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          );
        }
        final catalog = snapshot.data;
        if (catalog == null) return _VodSkeleton(movies: _movies);
        return Row(
          children: [
            SizedBox(width: 248, child: _categories(catalog)),
            const VerticalDivider(width: 1),
            Expanded(child: _grid(catalog)),
          ],
        );
      },
    );
  }

  Widget _categories(VodCatalog catalog) {
    final c = AppColors.of(context);
    final counts = _countsFor(catalog);
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
    // (anahtar, etiket, ikon, sayı, başlık mı, yıldızlı kategori mi)
    final rows = <(String?, String, IconData?, int?, bool, bool)>[
      if (query.isEmpty)
        (null, _movies ? 'Tüm filmler' : 'Tüm diziler', Icons.apps,
            catalog.items.length, false, false),
      if (query.isEmpty && resumable > 0)
        (_continueKey, 'İzlemeye devam et', Icons.history, resumable, false,
            false),
      if (pinned.isNotEmpty) ...[
        (null, 'Favori paketler', null, null, true, false),
        for (final cat in pinned)
          (cat.id, cat.name, null, counts[cat.id], false, true),
      ],
      if (query.isEmpty) (null, 'Tüm kategoriler', null, null, true, false),
      for (final cat in cats)
        (cat.id, cat.name, null, counts[cat.id], false, true),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.sm, Space.sm, Space.sm, Space.xxs),
          child: SearchField(
            hint: 'Kategori ara',
            onChanged: (v) => setState(() => _categoryQuery = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: Space.md),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final (key, label, icon, count, header, category) = rows[i];
              if (header) return SectionHeader(label);
              final favorite =
                  category && favorites.contains(_groupKey(key!));
              return NavRow(
                label: label,
                leading: icon,
                count: count,
                selected: key == _category,
                onTap: () => setState(() => _category = key),
                showTrailing: favorite,
                trailing: category
                    ? IconButton(
                        tooltip: favorite
                            ? 'Favori paketlerden çıkar'
                            : 'Favori paketlere ekle',
                        iconSize: IconSizes.md,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(favorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded),
                        color: favorite ? c.accent : c.fgMuted,
                        onPressed: () => _toggleFavoriteGroup(key!),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _grid(VodCatalog catalog) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final items = _visible(catalog);
    final noun = _movies ? 'film' : 'dizi';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.lg, Space.sm, Space.lg, Space.sm),
          child: Row(
            children: [
              Expanded(
                child: SearchField(
                  hint: _movies ? 'Film ara' : 'Dizi ara',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: Space.md),
              Text('${formatCount(items.length)} $noun',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: c.fgMuted)),
              const SizedBox(width: Space.sm),
              MenuAnchor(
                alignmentOffset: const Offset(0, 4),
                menuChildren: [
                  for (final s in _Sort.values)
                    MenuItemButton(
                      leadingIcon: Icon(
                        s == _sort ? Icons.check : null,
                        size: IconSizes.md,
                      ),
                      onPressed: () => setState(() => _sort = s),
                      child: Text(s.label),
                    ),
                ],
                builder: (context, controller, _) => OutlinedButton.icon(
                  onPressed: () => controller.isOpen
                      ? controller.close()
                      : controller.open(),
                  icon: const Icon(Icons.sort, size: IconSizes.md),
                  label: Text(_sort.label),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'Eşleşen $noun yok',
                  message: 'Aramayı ya da kategoriyi değiştir.',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      Space.lg, Space.sm, Space.lg, Space.lg),
                  gridDelegate: _gridDelegate,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final p = _progress[item.key];
                    return PosterCard(
                      title: item.name,
                      poster: item.poster,
                      subtitle: item.year?.toString(),
                      rating: item.rating,
                      progress: p != null && p.resumable ? p.fraction : null,
                      fallbackIcon: _movies
                          ? Icons.movie_outlined
                          : Icons.video_library_outlined,
                      onTap: () => _open(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Katalog yüklenirken ekranın iskeleti (15 saniyeyi bulabiliyor).
class _VodSkeleton extends StatelessWidget {
  const _VodSkeleton({required this.movies});

  final bool movies;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      label: movies ? 'Filmler yükleniyor' : 'Diziler yükleniyor',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 248,
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(height: 40, radius: Radii.mdAll),
                    const SizedBox(height: Space.md),
                    for (var i = 0; i < 14; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Skeleton(
                            height: 14, width: 110.0 + (i * 41) % 100),
                      ),
                  ],
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1, color: c.border),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Space.lg, Space.sm, Space.lg, Space.sm),
                  child: Row(
                    children: [
                      const Expanded(
                          child: Skeleton(height: 40, radius: Radii.mdAll)),
                      const SizedBox(width: Space.md),
                      Text(
                        movies
                            ? 'Filmler yükleniyor…'
                            : 'Diziler yükleniyor…',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: c.fgMuted),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                        Space.lg, Space.sm, Space.lg, Space.lg),
                    gridDelegate: _gridDelegate,
                    itemCount: 24,
                    itemBuilder: (_, i) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                            child: Skeleton(radius: Radii.mdAll)),
                        const SizedBox(height: Space.xs),
                        Skeleton(height: 12, width: 90.0 + (i * 29) % 60),
                        const SizedBox(height: 6),
                        const Skeleton(height: 10, width: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Filmde ayrıntı penceresini açar ve seçilirse oynatır; dizide dizi
/// sayfasını açar. Ana sayfa ve arama da kullanır.
Future<void> openVodItem(
  BuildContext context, {
  required XtreamSource source,
  required VodItem item,
  required WatchProgressStore progressStore,
  WatchProgress? progress,
}) async {
  final navigator = Navigator.of(context);
  if (item.kind == VodKind.series) {
    await navigator.push(MaterialPageRoute<void>(
      builder: (_) => _SeriesScreen(
        source: source,
        series: item,
        progressStore: progressStore,
      ),
    ));
    return;
  }
  final choice = await showDialog<_PlayChoice>(
    context: context,
    builder: (_) =>
        _MovieDialog(source: source, movie: item, progress: progress),
  );
  if (choice == null) return;
  await navigator.push(MaterialPageRoute<void>(
    builder: (_) => VodPlayerScreen(
      title: item.name,
      url: movieUrl(source, item),
      source: source,
      progressKey: item.key,
      progressMeta: WatchMeta(
        title: item.name,
        poster: item.poster,
        streamId: item.id,
        extension: item.extension ?? 'mp4',
      ),
      progressStore: progressStore,
      start: choice.start,
    ),
  ));
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
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final progress = widget.progress;
    final resumable = progress != null && progress.resumable;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: c.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 540),
        child: FutureBuilder<VodDetails>(
          future: _details,
          builder: (context, snapshot) {
            final d = snapshot.data;
            final loading = snapshot.connectionState != ConnectionState.done;
            return Stack(
              children: [
                Positioned.fill(
                    child: Backdrop(url: d?.backdrop ?? movie.poster)),
                Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: Radii.mdAll,
                          border: Border.all(color: c.border),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xAA000000),
                                blurRadius: 30,
                                offset: Offset(0, 12)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: Radii.mdAll,
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: PosterImage(
                                url: movie.poster, cacheWidth: 440),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.name,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall),
                            const SizedBox(height: Space.sm),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (movie.rating case final r? when r > 0)
                                  MetaChip(r.toStringAsFixed(1),
                                      icon: Icons.star_rounded,
                                      iconColor: c.warning),
                                if (movie.year case final y?) MetaChip('$y'),
                                if (d?.duration case final t?)
                                  MetaChip(formatDuration(t),
                                      icon: Icons.schedule),
                                if (d?.genre case final g?) MetaChip(g),
                              ],
                            ),
                            const SizedBox(height: Space.md),
                            Expanded(
                              child: loading
                                  ? const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Skeleton(height: 12),
                                        SizedBox(height: 8),
                                        Skeleton(height: 12),
                                        SizedBox(height: 8),
                                        Skeleton(height: 12, width: 220),
                                      ],
                                    )
                                  : SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            d?.plot ??
                                                movie.plot ??
                                                'Açıklama yok.',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: c.fg
                                                        .withValues(
                                                            alpha: 0.9)),
                                          ),
                                          if (d?.director case final dir?)
                                            _Credit(
                                                label: 'Yönetmen', value: dir),
                                          if (d?.cast case final cast?)
                                            _Credit(
                                                label: 'Oyuncular',
                                                value: cast),
                                        ],
                                      ),
                                    ),
                            ),
                            const SizedBox(height: Space.md),
                            if (resumable) ...[
                              SizedBox(
                                width: 260,
                                child: ClipRRect(
                                  borderRadius: Radii.smAll,
                                  child: LinearProgressIndicator(
                                    value: progress.fraction,
                                    minHeight: 4,
                                    backgroundColor: c.border,
                                  ),
                                ),
                              ),
                              const SizedBox(height: Space.sm),
                            ],
                            Wrap(
                              spacing: Space.sm,
                              runSpacing: Space.xs,
                              children: [
                                if (resumable) ...[
                                  FilledButton.icon(
                                    autofocus: true,
                                    onPressed: () => _play(context,
                                        start: progress.position),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: Text('Devam et · '
                                        '${formatPosition(progress.position)}'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _play(context),
                                    icon: const Icon(Icons.replay),
                                    label: const Text('Baştan başla'),
                                  ),
                                ] else
                                  FilledButton.icon(
                                    autofocus: true,
                                    onPressed: () => _play(context),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text('Oynat'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: Space.xs,
                  right: Space.xs,
                  child: IconButton(
                    tooltip: 'Kapat',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
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

/// "Yönetmen: ..." gibi künye satırı.
class _Credit extends StatelessWidget {
  const _Credit({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
              text: '$label  ',
              style: theme.textTheme.labelMedium?.copyWith(color: c.fgMuted)),
          TextSpan(text: value, style: theme.textTheme.bodySmall
              ?.copyWith(color: c.fg)),
        ]),
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
        progressMeta: WatchMeta(
          title: widget.series.name,
          subtitle: 'S${e.season} B${e.number} · ${e.title}',
          poster: widget.series.poster,
          streamId: e.id,
          extension: e.extension,
          seriesId: widget.series.id,
        ),
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
    final c = AppColors.of(context);
    return Scaffold(
      body: FutureBuilder<SeriesDetails>(
        future: _details,
        builder: (context, snapshot) {
          final d = snapshot.data;
          final Widget body;
          if (snapshot.hasError) {
            body = EmptyState(
              icon: Icons.cloud_off_outlined,
              tone: c.danger,
              title: 'Dizi bilgisi alınamadı',
              message: '${snapshot.error}',
              actions: [
                FilledButton.icon(
                  onPressed: () => setState(() => _details =
                      loadSeriesDetails(widget.source, widget.series.id)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar dene'),
                ),
              ],
            );
          } else if (d == null) {
            body = _content(null);
          } else if (d.seasons.isEmpty) {
            body = const EmptyState(
                icon: Icons.video_library_outlined,
                title: 'Bu dizide bölüm yok');
          } else {
            body = _content(d);
          }
          return Stack(
            children: [
              Positioned.fill(
                  child: Backdrop(url: d?.info.backdrop ?? widget.series.poster)),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Space.xs, Space.xs, Space.md, 0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Geri',
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: Space.xs),
                        Text('DİZİLER',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: c.fgMuted)),
                      ],
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// [d] null ise bölümlerin yerinde iskelet.
  Widget _content(SeriesDetails? d) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final series = widget.series;
    final next = d == null ? null : _nextUp(d);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 340,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.xs, Space.lg, Space.lg),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: Radii.mdAll,
                      border: Border.all(color: c.border),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xAA000000),
                            blurRadius: 24,
                            offset: Offset(0, 10)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: Radii.mdAll,
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: PosterImage(
                            url: series.poster,
                            fallbackIcon: Icons.video_library_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(series.name,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: Space.sm),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (series.rating case final r? when r > 0)
                              MetaChip(r.toStringAsFixed(1),
                                  icon: Icons.star_rounded,
                                  iconColor: c.warning),
                            if (series.year case final y?) MetaChip('$y'),
                            if (d != null)
                              MetaChip('${d.seasons.length} sezon'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              if (d?.info.genre case final g?)
                Text(g,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: c.fgMuted)),
              const SizedBox(height: Space.md),
              if (next != null) ...[
                FilledButton.icon(
                  autofocus: true,
                  onPressed: () => _play(next),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('S${next.season} B${next.number} · '
                      '${_progress[next.key]?.resumable ?? false ? 'Devam et' : 'Oynat'}'),
                ),
                const SizedBox(height: Space.md),
              ],
              if (d == null) ...const [
                Skeleton(height: 12),
                SizedBox(height: 8),
                Skeleton(height: 12),
                SizedBox(height: 8),
                Skeleton(height: 12, width: 180),
              ] else ...[
                Text(d.info.plot ?? series.plot ?? '',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: c.fg.withValues(alpha: 0.9))),
                if (d.info.cast case final cast?)
                  _Credit(label: 'Oyuncular', value: cast),
                if (d.info.director case final dir?)
                  _Credit(label: 'Yönetmen', value: dir),
              ],
            ],
          ),
        ),
        Expanded(
          child: d == null
              ? ListView(
                  padding: const EdgeInsets.all(Space.lg),
                  children: [
                    for (var i = 0; i < 6; i++)
                      const Padding(
                        padding: EdgeInsets.only(bottom: Space.md),
                        child: Row(
                          children: [
                            Skeleton(
                                width: 144, height: 81, radius: Radii.mdAll),
                            SizedBox(width: Space.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Skeleton(height: 14, width: 220),
                                  SizedBox(height: 8),
                                  Skeleton(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : DefaultTabController(
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
                          for (final MapEntry(key: s, value: list)
                              in d.seasons.entries)
                            Tab(text: '$s. sezon  ·  ${list.length}'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            for (final list in d.seasons.values)
                              ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    Space.md, Space.sm, Space.md, Space.lg),
                                itemCount: list.length,
                                itemBuilder: (context, i) => _EpisodeRow(
                                  episode: list[i],
                                  progress: _progress[list[i].key],
                                  next: identical(list[i], next),
                                  fallbackPoster: series.poster,
                                  onTap: () => _play(list[i]),
                                ),
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
  }
}

/// Bölüm satırı: küçük görsel, numara, ad, özet, süre ve ilerleme.
class _EpisodeRow extends StatefulWidget {
  const _EpisodeRow({
    required this.episode,
    required this.progress,
    required this.next,
    required this.fallbackPoster,
    required this.onTap,
  });

  final Episode episode;
  final WatchProgress? progress;

  /// Sıradaki bölüm; hafifçe vurgulanır.
  final bool next;
  final String? fallbackPoster;
  final VoidCallback onTap;

  @override
  State<_EpisodeRow> createState() => _EpisodeRowState();
}

class _EpisodeRowState extends State<_EpisodeRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final e = widget.episode;
    final p = widget.progress;
    final finished = p != null && p.finished;
    final partial = p != null && !p.finished && p.resumable;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: Radii.mdAll,
            hoverColor: Colors.transparent,
            child: AnimatedContainer(
              duration: motion.fast,
              padding: const EdgeInsets.all(Space.xs),
              decoration: BoxDecoration(
                color: _hovered
                    ? c.surfaceRaised
                    : widget.next
                        ? c.muted.withValues(alpha: 0.7)
                        : Colors.transparent,
                borderRadius: Radii.mdAll,
                border: Border.all(
                    color: widget.next
                        ? c.accent.withValues(alpha: 0.5)
                        : Colors.transparent),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 144,
                    height: 81,
                    child: ClipRRect(
                      borderRadius: Radii.smAll,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PosterImage(
                            url: e.image ?? widget.fallbackPoster,
                            cacheWidth: 288,
                            fallbackIcon: Icons.movie_outlined,
                          ),
                          AnimatedOpacity(
                            duration: motion.fast,
                            opacity: _hovered ? 1 : 0,
                            child: ColoredBox(
                              color: c.scrim.withValues(alpha: 0.5),
                              child: Icon(Icons.play_arrow_rounded,
                                  size: 36, color: c.fg),
                            ),
                          ),
                          if (partial || finished)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: LinearProgressIndicator(
                                value: finished ? 1 : p.fraction,
                                minHeight: 3,
                                color: finished ? c.fgMuted : c.accent,
                                backgroundColor: const Color(0x66000000),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${e.number}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                    color: widget.next ? c.accent : c.fgMuted,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ])),
                            const SizedBox(width: Space.xs),
                            Expanded(
                              child: Text(e.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall),
                            ),
                            if (finished)
                              Tooltip(
                                message: 'İzlendi',
                                child: Icon(Icons.check_circle,
                                    size: IconSizes.md, color: c.success),
                              )
                            else if (e.duration case final t?)
                              Text(formatDuration(t),
                                  style: theme.textTheme.labelMedium
                                      ?.copyWith(color: c.fgMuted)),
                          ],
                        ),
                        if (e.plot case final plot?)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(plot,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall),
                          ),
                        if (partial)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                                '${formatPosition(p.position)} izlendi',
                                style: theme.textTheme.labelMedium
                                    ?.copyWith(color: c.accent)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

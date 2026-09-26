import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/epg.dart';
import '../models/playlist.dart';
import '../models/vod.dart';
import '../ui/tokens.dart';
import '../ui/widgets/channel_tile.dart';
import '../ui/widgets/common.dart';
import '../ui/widgets/poster.dart';
import '../ui/widgets/shelf.dart';

/// Bir raftaki en fazla sonuç; tamamı sayı olarak gösterilir.
const _maxResults = 40;

/// Sonuç türü: Tümü raflarla, diğerleri dikey kaydırılan tam listeyle.
enum _Filter { all, channels, movies, series }

/// Kanal, film ve dizilerde tek kutudan arama.
class SearchView extends StatefulWidget {
  const SearchView({
    super.key,
    required this.playlist,
    required this.catalog,
    this.hiddenGroups = const {},
    this.hiddenVod = const {},
    required this.nowOn,
    required this.now,
    required this.onPlayChannel,
    required this.onOpenVod,
  });

  /// Kanal listesi; yüklenmediyse null.
  final Playlist? playlist;

  /// Kullanıcının gizlediği kanal kategorileri; aramada çıkmaz.
  final Set<String> hiddenGroups;

  /// Gizlenen film ve dizi kategorileri (kategori kimliği).
  final Map<VodKind, Set<String>> hiddenVod;

  /// Film ya da dizi kataloğu; M3U listede null.
  final Future<VodCatalog> Function(VodKind kind)? catalog;
  final Programme? Function(Channel channel) nowOn;
  final DateTime now;
  final ValueChanged<Channel> onPlayChannel;
  final ValueChanged<VodItem> onOpenVod;

  @override
  State<SearchView> createState() => _SearchViewState();
}

/// Arama anahtarları büyük listelerde her tuşta yeniden hesaplanmasın.
final _channelKeys = Expando<List<String>>();
final _itemKeys = Expando<List<String>>();

class _SearchViewState extends State<SearchView> {
  String _query = '';
  _Filter _filter = _Filter.all;
  Timer? _debounce;
  Future<VodCatalog>? _movies;
  Future<VodCatalog>? _series;

  @override
  void initState() {
    super.initState();
    // Aramaya girildiyse kataloglar gerekecek; beklemeyi şimdiden başlat.
    _movies = widget.catalog?.call(VodKind.movie);
    _series = widget.catalog?.call(VodKind.series);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _query = v);
    });
  }

  List<Channel> _channels(String query) {
    final playlist = widget.playlist;
    if (playlist == null) return const [];
    final channels = playlist.channels;
    final keys = _channelKeys[playlist] ??=
        [for (final c in channels) searchKey(c.name)];
    final hidden = widget.hiddenGroups;
    return [
      for (var i = 0; i < channels.length; i++)
        if (!channels[i].isSeparator &&
            keys[i].contains(query) &&
            !hidden.contains(channels[i].group ?? Playlist.ungrouped))
          channels[i],
    ];
  }

  static List<VodItem> _items(VodCatalog catalog, String query) {
    final items = catalog.items;
    final keys = _itemKeys[catalog] ??= [for (final i in items) searchKey(i.name)];
    return [
      for (var i = 0; i < items.length; i++)
        if (keys[i].contains(query)) items[i],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final query = searchKey(_query.trim());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.xl, Space.lg, Space.xl, Space.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SearchField(
                hint: widget.catalog == null
                    ? context.l10n.searchChannels
                    : context.l10n.searchHintAll,
                autofocus: true,
                onChanged: _onChanged,
              ),
            ),
          ),
        ),
        if (query.length >= 2) _filters(query),
        Expanded(
          child: query.length < 2
              ? EmptyState(
                  icon: Icons.search,
                  title: context.l10n.searchPromptTitle,
                  message: widget.catalog == null
                      ? context.l10n.searchPromptChannels
                      : context.l10n.searchPromptAll,
                )
              : switch (_filter) {
                  _Filter.all => _results(query),
                  _Filter.channels => _channelList(query),
                  _Filter.movies => _vodGrid(VodKind.movie, query),
                  _Filter.series => _vodGrid(VodKind.series, query),
                },
        ),
      ],
    );
  }

  Future<VodCatalog>? _catalogOf(VodKind kind) =>
      kind == VodKind.movie ? _movies : _series;

  /// Katalogdaki eşleşmeler; gizli (ve kilitli) kategoriler hariç.
  List<VodItem> _vodResults(VodCatalog catalog, VodKind kind, String query) {
    final hidden = widget.hiddenVod[kind] ?? const <String>{};
    return [
      for (final i in _items(catalog, query))
        if (!hidden.contains(i.categoryId)) i,
    ];
  }

  /// Tümü · Kanallar · Filmler · Diziler; türlerde sonuç sayısı.
  Widget _filters(String query) {
    final c = AppColors.of(context);
    final l = context.l10n;
    Widget chip(_Filter filter, String label,
        {int? count, bool loading = false}) {
      final selected = _filter == filter;
      final color = selected ? c.onAccent : c.fg;
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: Space.xs),
        child: ChoiceChip(
          showCheckmark: false,
          selected: selected,
          onSelected: (_) => setState(() => _filter = filter),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: color)),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text(l.count(count),
                    style: TextStyle(
                        color: selected ? c.onAccent : c.fgMuted,
                        fontFeatures: const [FontFeature.tabularFigures()])),
              ],
              if (loading) ...[
                const SizedBox(width: 6),
                SizedBox.square(
                  dimension: 10,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: c.fgMuted),
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget vodChip(_Filter filter, String label, VodKind kind) =>
        FutureBuilder<VodCatalog>(
          future: _catalogOf(kind),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const SizedBox.shrink();
            final data = snapshot.data;
            return chip(filter, label,
                count: data == null ? null : _vodResults(data, kind, query).length,
                loading: data == null);
          },
        );

    final playlist = widget.playlist;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.md),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          runSpacing: Space.xs,
          children: [
            chip(_Filter.all, l.searchFilterAll),
            chip(_Filter.channels, l.channels,
                count: playlist == null ? null : _channels(query).length,
                loading: playlist == null),
            if (_movies != null)
              vodChip(_Filter.movies, l.sectionMovies, VodKind.movie),
            if (_series != null)
              vodChip(_Filter.series, l.sectionSeries, VodKind.series),
          ],
        ),
      ),
    );
  }

  /// Rafın başlığındaki "Tümünü gör": o türün tam listesine geçer.
  Widget _seeAll(_Filter filter) => TextButton(
        onPressed: () => setState(() => _filter = filter),
        child: Text(context.l10n.seeAll),
      );

  static Widget _loading() => const Center(
        child: SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );

  Widget _noResults() => EmptyState(
        icon: Icons.search_off,
        title: context.l10n.noResultsTitle,
        message: context.l10n.noResultsMessage,
      );

  /// Tüm eşleşen kanallar, fare tekerleğiyle kaydırılan ızgarada.
  Widget _channelList(String query) {
    final l = context.l10n;
    if (widget.playlist == null) return _loading();
    final channels = _channels(query);
    if (channels.isEmpty) return _noResults();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
          Space.xl - Space.xs, 0, Space.xl - Space.xs, Space.xxl),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisExtent: ChannelTile.height + 4,
      ),
      itemCount: channels.length,
      itemBuilder: (context, i) {
        final channel = channels[i];
        final programme = widget.nowOn(channel);
        return ChannelTile(
          name: channel.name,
          logo: channel.logo,
          // Program yoksa kanalın kategorisi.
          programme: programme?.title ??
              (channel.group == null ? null : l.group(channel.group!)),
          progress: programme?.progress(widget.now),
          onTap: () => widget.onPlayChannel(channel),
        );
      },
    );
  }

  /// Tüm eşleşen filmler ya da diziler, poster ızgarasında.
  Widget _vodGrid(VodKind kind, String query) => FutureBuilder<VodCatalog>(
        future: _catalogOf(kind),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _noResults();
          final data = snapshot.data;
          if (data == null) return _loading();
          final items = _vodResults(data, kind, query);
          if (items.isEmpty) return _noResults();
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
                Space.xl, Space.xs, Space.xl, Space.xxl),
            gridDelegate: posterGridDelegate,
            itemCount: items.length,
            itemBuilder: (context, i) => _poster(items[i]),
          );
        },
      );

  Widget _poster(VodItem item) => PosterCard(
        title: item.name,
        poster: item.poster,
        rating: item.rating,
        subtitle: item.year?.toString(),
        fallbackIcon: item.kind == VodKind.movie
            ? Icons.movie_outlined
            : Icons.video_library_outlined,
        onTap: () => widget.onOpenVod(item),
      );

  Widget _results(String query) {
    final l = context.l10n;
    final channels = _channels(query);
    final movies = _movies, series = _series;
    return ListView(
      padding: const EdgeInsets.only(bottom: Space.xxl),
      children: [
        if (widget.playlist == null)
          _loadingShelf(l.channels, ChannelCard.width, ChannelCard.height)
        else if (channels.isNotEmpty)
          Shelf(
            title: l.channels,
            count: channels.length,
            action: _seeAll(_Filter.channels),
            itemCount: channels.length.clamp(0, _maxResults),
            itemWidth: ChannelCard.width,
            height: ChannelCard.height,
            itemBuilder: (context, i) {
              final channel = channels[i];
              final programme = widget.nowOn(channel);
              return ChannelCard(
                name: channel.name,
                logo: channel.logo,
                programme: programme?.title,
                progress: programme?.progress(widget.now),
                caption: channel.group == null ? null : l.group(channel.group!),
                onTap: () => widget.onPlayChannel(channel),
              );
            },
          ),
        if (movies != null)
          _vodShelf(l.sectionMovies, VodKind.movie, movies, query),
        if (series != null)
          _vodShelf(l.sectionSeries, VodKind.series, series, query),
        _NoResults(
          query: query,
          channels: channels.length,
          movies: movies,
          series: series,
          itemsOf: _items,
        ),
      ],
    );
  }

  Widget _loadingShelf(String title, double width, double height) => Padding(
        padding: const EdgeInsets.only(bottom: Space.xl),
        child: Shelf(
          title: context.l10n.loadingSection(title),
          itemCount: 6,
          itemWidth: width,
          height: height,
          itemBuilder: (_, _) => const Skeleton(radius: Radii.lgAll),
        ),
      );

  Widget _vodShelf(String title, VodKind kind, Future<VodCatalog> catalog,
      String query) {
    return FutureBuilder<VodCatalog>(
      future: catalog,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.hasError) return const SizedBox.shrink();
        if (data == null) return _loadingShelf(title, 150, 280);
        final items = _vodResults(data, kind, query);
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: Space.xl),
          child: Shelf(
            title: title,
            count: items.length,
            action: _seeAll(
                kind == VodKind.movie ? _Filter.movies : _Filter.series),
            itemCount: items.length.clamp(0, _maxResults),
            itemWidth: 150,
            height: 280,
            itemBuilder: (context, i) => _poster(items[i]),
          ),
        );
      },
    );
  }
}

/// Hiçbir rafta sonuç yoksa (ve yükleme bittiyse) açıklama.
class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.query,
    required this.channels,
    required this.movies,
    required this.series,
    required this.itemsOf,
  });

  final String query;
  final int channels;
  final Future<VodCatalog>? movies;
  final Future<VodCatalog>? series;
  final List<VodItem> Function(VodCatalog, String) itemsOf;

  /// Yükleme hatası "sonuç yok" sayılır; hata raflarda zaten gizli.
  static Future<VodCatalog?> _settled(Future<VodCatalog>? f) async {
    if (f == null) return null;
    try {
      return await f;
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (channels > 0) return const SizedBox.shrink();
    return FutureBuilder<List<VodCatalog?>>(
      future: Future.wait([_settled(movies), _settled(series)]),
      builder: (context, snapshot) {
        final catalogs = snapshot.data;
        if (catalogs == null) return const SizedBox.shrink();
        final any = catalogs.any((c) => c != null && itemsOf(c, query).isNotEmpty);
        if (any) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: Space.xxl),
          child: EmptyState(
            icon: Icons.search_off,
            title: context.l10n.noResultsTitle,
            message: context.l10n.noResultsMessage,
          ),
        );
      },
    );
  }
}

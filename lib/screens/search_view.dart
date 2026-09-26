import 'dart:async';

import 'package:flutter/material.dart';

import '../models/epg.dart';
import '../models/playlist.dart';
import '../models/vod.dart';
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';
import '../ui/widgets/poster.dart';
import '../ui/widgets/shelf.dart';

/// Bir raftaki en fazla sonuç; tamamı sayı olarak gösterilir.
const _maxResults = 40;

/// Kanal, film ve dizilerde tek kutudan arama.
class SearchView extends StatefulWidget {
  const SearchView({
    super.key,
    required this.playlist,
    required this.catalog,
    required this.nowOn,
    required this.now,
    required this.onPlayChannel,
    required this.onOpenVod,
  });

  /// Kanal listesi; yüklenmediyse null.
  final Playlist? playlist;

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
    return [
      for (var i = 0; i < channels.length; i++)
        if (!channels[i].isSeparator && keys[i].contains(query)) channels[i],
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
              alignment: Alignment.centerLeft,
              child: SearchField(
                hint: widget.catalog == null
                    ? 'Kanal ara'
                    : 'Kanal, film ya da dizi ara',
                autofocus: true,
                onChanged: _onChanged,
              ),
            ),
          ),
        ),
        Expanded(
          child: query.length < 2
              ? EmptyState(
                  icon: Icons.search,
                  title: 'Ne izlemek istersin?',
                  message: widget.catalog == null
                      ? 'En az iki harf yaz; kanallarda aranır.'
                      : 'En az iki harf yaz; kanallarda, filmlerde ve '
                          'dizilerde aynı anda aranır.',
                )
              : _results(query),
        ),
      ],
    );
  }

  Widget _results(String query) {
    final channels = _channels(query);
    final movies = _movies, series = _series;
    return ListView(
      padding: const EdgeInsets.only(bottom: Space.xxl),
      children: [
        if (widget.playlist == null)
          _loadingShelf('Kanallar', ChannelCard.width, ChannelCard.height)
        else if (channels.isNotEmpty)
          Shelf(
            title: 'Kanallar',
            count: channels.length,
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
                caption: channel.group,
                onTap: () => widget.onPlayChannel(channel),
              );
            },
          ),
        if (movies != null) _vodShelf('Filmler', movies, query),
        if (series != null) _vodShelf('Diziler', series, query),
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
          title: '$title yükleniyor…',
          itemCount: 6,
          itemWidth: width,
          height: height,
          itemBuilder: (_, _) => const Skeleton(radius: Radii.lgAll),
        ),
      );

  Widget _vodShelf(String title, Future<VodCatalog> catalog, String query) {
    return FutureBuilder<VodCatalog>(
      future: catalog,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.hasError) return const SizedBox.shrink();
        if (data == null) return _loadingShelf(title, 150, 280);
        final items = _items(data, query);
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: Space.xl),
          child: Shelf(
            title: title,
            count: items.length,
            itemCount: items.length.clamp(0, _maxResults),
            itemWidth: 150,
            height: 280,
            itemBuilder: (context, i) {
              final item = items[i];
              return PosterCard(
                title: item.name,
                poster: item.poster,
                rating: item.rating,
                subtitle: item.year?.toString(),
                fallbackIcon: item.kind == VodKind.movie
                    ? Icons.movie_outlined
                    : Icons.video_library_outlined,
                onTap: () => widget.onOpenVod(item),
              );
            },
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
        return const Padding(
          padding: EdgeInsets.only(top: Space.xxl),
          child: EmptyState(
            icon: Icons.search_off,
            title: 'Sonuç bulunamadı',
            message: 'Farklı bir yazımla dene; Türkçe harfler fark etmez.',
          ),
        );
      },
    );
  }
}

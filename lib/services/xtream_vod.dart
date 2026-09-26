import 'package:flutter/foundation.dart';

import '../models/playlist_source.dart';
import '../models/vod.dart';
import 'playlist_loader.dart';
import 'watch_progress_store.dart';
import 'xtream_client.dart';

/// Film ya da dizi kataloğunu (kategoriler ve tüm öğeler) yükler.
Future<VodCatalog> loadVodCatalog(XtreamSource source, VodKind kind) async {
  final movie = kind == VodKind.movie;
  final (categories, items) = await (
    xtreamApi(source, {
      'action': movie ? 'get_vod_categories' : 'get_series_categories',
    }),
    xtreamApi(source, {'action': movie ? 'get_vod_streams' : 'get_series'}),
  ).wait;
  final catalog = await compute(
    (_) => parseVodCatalog(kind, categories, items),
    null,
  );
  if (catalog.items.isEmpty) {
    throw PlaylistException(
        movie ? PlaylistError.noMovies : PlaylistError.noSeries);
  }
  return catalog;
}

Future<VodDetails> loadMovieDetails(XtreamSource source, String id) async {
  final json = await xtreamApi(
      source, {'action': 'get_vod_info', 'vod_id': id});
  final info = json is Map<String, dynamic> ? json['info'] : null;
  return parseVodDetails(info is Map<String, dynamic> ? info : const {});
}

Future<SeriesDetails> loadSeriesDetails(XtreamSource source, String id) async {
  final json = await xtreamApi(
      source, {'action': 'get_series_info', 'series_id': id});
  return parseSeriesDetails(json is Map<String, dynamic> ? json : const {});
}

String movieUrl(XtreamSource source, VodItem movie) =>
    '${source.server}/movie/${_credentials(source)}/${movie.id}'
    '.${movie.extension ?? 'mp4'}';

String episodeUrl(XtreamSource source, Episode episode) =>
    '${source.server}/series/${_credentials(source)}/${episode.id}'
    '.${episode.extension}';

/// "İzlemeye devam et" kaydından film ya da bölüm adresi.
String watchUrl(XtreamSource source, WatchMeta meta) =>
    '${source.server}/${meta.isEpisode ? 'series' : 'movie'}/'
    '${_credentials(source)}/${meta.streamId}.${meta.extension}';

/// Geçmiş yayın adresi. Başlangıç sunucu saatiyle `yyyy-MM-dd:HH-mm`
/// biçiminde yazılır; fark bilinmiyorsa cihazın yerel saati kullanılır.
String catchupUrl(
  XtreamSource source, {
  required String streamId,
  required DateTime start,
  required Duration duration,
  Duration? serverOffset,
}) {
  final t = serverOffset == null
      ? start.toLocal()
      : start.toUtc().add(serverOffset);
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp = '${t.year}-${two(t.month)}-${two(t.day)}:'
      '${two(t.hour)}-${two(t.minute)}';
  final minutes = (duration.inSeconds / 60).ceil();
  return '${source.server}/timeshift/${_credentials(source)}/$minutes/'
      '$stamp/$streamId.ts';
}

String _credentials(XtreamSource source) =>
    '${Uri.encodeComponent(source.username)}/'
    '${Uri.encodeComponent(source.password)}';

@visibleForTesting
VodCatalog parseVodCatalog(VodKind kind, Object? categories, Object? items) {
  final movie = kind == VodKind.movie;
  final cats = [
    for (final c in _maps(categories))
      if (c['category_id'] != null)
        VodCategory(
          id: '${c['category_id']}',
          name: _text(c['category_name']) ?? 'Kategori',
        ),
  ];
  final list = <VodItem>[
    for (final i in _maps(items))
      if (i[movie ? 'stream_id' : 'series_id'] case final id?)
        VodItem(
          kind: kind,
          id: '$id',
          name: _text(i['name']) ?? (movie ? 'Film $id' : 'Dizi $id'),
          categoryId: i['category_id']?.toString(),
          poster: _text(i[movie ? 'stream_icon' : 'cover']),
          rating: _rating(i['rating']),
          year: _year(i['year']) ??
              _year(i['releaseDate']) ??
              _year(i['release_date']),
          extension: movie ? _text(i['container_extension']) : null,
          plot: _text(i['plot']),
        ),
  ];
  return VodCatalog(categories: cats, items: list);
}

@visibleForTesting
VodDetails parseVodDetails(Map<String, dynamic> info) {
  final backdrop = info['backdrop_path'];
  return VodDetails(
    plot: _text(info['plot']) ?? _text(info['description']),
    genre: _text(info['genre']),
    cast: _text(info['cast']) ?? _text(info['actors']),
    director: _text(info['director']),
    releaseDate: _text(info['releasedate']) ??
        _text(info['releaseDate']) ??
        _text(info['release_date']),
    duration: _duration(info['duration_secs'], info['duration']),
    backdrop: backdrop is List && backdrop.isNotEmpty
        ? _text(backdrop.first)
        : _text(backdrop),
  );
}

@visibleForTesting
SeriesDetails parseSeriesDetails(Map<String, dynamic> json) {
  final info = json['info'];
  final seasons = <int, List<Episode>>{};
  final episodes = json['episodes'];
  // Sağlayıcıya göre sezon -> liste haritası ya da liste listesi.
  final groups = switch (episodes) {
    Map<String, dynamic>() => episodes.values,
    List<dynamic>() => episodes,
    _ => const <Object?>[],
  };
  for (final group in groups) {
    for (final e in _maps(group)) {
      final id = e['id'];
      if (id == null) continue;
      final season = int.tryParse('${e['season']}') ?? 1;
      final number = int.tryParse('${e['episode_num']}') ?? 0;
      final meta = e['info'] is Map<String, dynamic>
          ? e['info'] as Map<String, dynamic>
          : const <String, dynamic>{};
      (seasons[season] ??= []).add(Episode(
        id: '$id',
        season: season,
        number: number,
        // Adsız bölümün adı arayüz dilinde ekranda kurulur.
        title: _text(e['title']) ?? '',
        extension: _text(e['container_extension']) ?? 'mp4',
        plot: _text(meta['plot']),
        duration: _duration(meta['duration_secs'], meta['duration']),
        image: _text(meta['movie_image']),
      ));
    }
  }
  for (final list in seasons.values) {
    list.sort((a, b) => a.number.compareTo(b.number));
  }
  return SeriesDetails(
    info: parseVodDetails(
        info is Map<String, dynamic> ? info : const <String, dynamic>{}),
    seasons: {
      for (final k in seasons.keys.toList()..sort()) k: seasons[k]!,
    },
  );
}

Iterable<Map<String, dynamic>> _maps(Object? list) =>
    list is List ? list.whereType<Map<String, dynamic>>() : const [];

String? _text(Object? value) {
  final s = value?.toString().trim();
  return s == null || s.isEmpty || s == 'null' ? null : s;
}

double? _rating(Object? value) {
  final r = double.tryParse('${value ?? ''}');
  return r == null || r <= 0 ? null : r.clamp(0, 10).toDouble();
}

int? _year(Object? value) {
  final m = RegExp(r'(19|20)\d\d').firstMatch('${value ?? ''}');
  return m == null ? null : int.parse(m.group(0)!);
}

Duration? _duration(Object? seconds, Object? text) {
  final s = int.tryParse('${seconds ?? ''}');
  if (s != null && s > 0) return Duration(seconds: s);
  // "01:52:10" biçimi.
  final parts = '${text ?? ''}'.split(':').map(int.tryParse).toList();
  if (parts.length == 3 && !parts.contains(null)) {
    final d = Duration(
        hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!);
    return d > Duration.zero ? d : null;
  }
  return null;
}

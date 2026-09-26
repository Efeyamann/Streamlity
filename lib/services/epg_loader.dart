import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/epg.dart';
import '../models/playlist.dart';
import 'epg_cache.dart';
import 'playlist_loader.dart';
import 'xmltv_parser.dart';

/// Diskteki kayıt bu süreden yeniyse sağlayıcıdan yeniden indirilmez.
const epgMaxAge = Duration(hours: 12);

/// Bu süreden eski kayıtlar silinir.
const _pruneAfter = Duration(days: 7);

/// [playlist]'in yayın akışını verir: önce diskteki kayıt (varsa, anında),
/// kayıt yoksa ya da [epgMaxAge]'den eskiyse ardından sağlayıcıdan indirilen
/// güncel hali. İndirme başarısız olursa kayıt varken hata verilmez.
///
/// Dosyalar onlarca MB olabildiği için okuma, indirme ve ayrıştırma ayrı
/// isolate'te yapılır. Listede EPG adresi yoksa hiçbir şey vermez.
Stream<Epg> loadEpg(Playlist playlist) async* {
  final urls = (playlist.epgUrl ?? '')
      .split(',')
      .map((u) => u.trim())
      .where((u) => u.startsWith('http://') || u.startsWith('https://'))
      .toList();
  if (urls.isEmpty) return;
  final ids = {
    for (final c in playlist.channels)
      if (c.tvgId != null) c.tvgId!.toLowerCase(),
  };
  if (ids.isEmpty) return;

  final directory = '${(await getApplicationCacheDirectory()).path}'
      '${Platform.pathSeparator}epg';
  yield* loadEpgWith(
    urls: urls,
    ids: ids,
    cache: EpgCache(directory),
    fetch: _fetch,
  );
}

/// [loadEpg]'in platformdan bağımsız kısmı; testte sahte indirici ve geçici
/// klasörle çalıştırılır.
Stream<Epg> loadEpgWith({
  required List<String> urls,
  required Set<String> ids,
  required EpgCache cache,
  required Future<List<int>> Function(String url) fetch,
}) async* {
  final cached = await _spawnRead(urls, ids, cache);
  if (cached.epg case final epg?) yield epg;
  if (cached.fresh) return;
  try {
    yield await _spawnDownload(urls, ids, cache, fetch);
  } on Exception {
    if (cached.epg == null) rethrow;
  }
}

// Ayrı fonksiyonlar: closure'ların kapsamdaki büyük nesneleri (ör. ilk
// okunan akış) yakalayıp isolate'e kopyalamasını önler.
Future<({Epg? epg, bool fresh})> _spawnRead(
        List<String> urls, Set<String> ids, EpgCache cache) =>
    Isolate.run(() => _readCached(urls, ids, cache));

Future<Epg> _spawnDownload(List<String> urls, Set<String> ids, EpgCache cache,
        Future<List<int>> Function(String url) fetch) =>
    Isolate.run(() => _download(urls, ids, cache, fetch));

Future<({Epg? epg, bool fresh})> _readCached(
    List<String> urls, Set<String> ids, EpgCache cache) async {
  final parts = <Epg>[];
  var fresh = true;
  for (final url in urls) {
    final entry = await cache.read(url);
    if (entry == null) {
      fresh = false;
      continue;
    }
    if (entry.age > epgMaxAge) fresh = false;
    parts.add(parseXmltv(utf8.decode(entry.xml, allowMalformed: true),
        only: ids));
  }
  return (epg: parts.isEmpty ? null : Epg.combine(parts), fresh: fresh);
}

Future<Epg> _download(List<String> urls, Set<String> ids, EpgCache cache,
    Future<List<int>> Function(String url) fetch) async {
  final parts = <Epg>[];
  Object? lastError;
  for (final url in urls) {
    try {
      var bytes = await fetch(url);
      await cache.write(url, bytes);
      // `.xml.gz` adresleri sıkıştırılmış gelir.
      if (isGzip(bytes)) bytes = gzip.decode(bytes);
      parts.add(parseXmltv(utf8.decode(bytes, allowMalformed: true),
          only: ids));
    } on Exception catch (e) {
      // Birden fazla adresten biri çalışmıyorsa diğerleriyle devam et.
      lastError = e;
    }
  }
  await cache.prune(_pruneAfter);
  if (parts.isEmpty) {
    throw PlaylistException(PlaylistError.epgFailed, '$lastError');
  }
  return Epg.combine(parts);
}

Future<List<int>> _fetch(String url) async {
  final response = await http
      .get(Uri.parse(url), headers: const {'User-Agent': userAgent})
      .timeout(const Duration(minutes: 2));
  if (response.statusCode != 200) {
    throw PlaylistException(
        PlaylistError.httpStatus, '${response.statusCode}');
  }
  return response.bodyBytes;
}

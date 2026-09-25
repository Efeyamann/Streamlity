import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import '../models/epg.dart';
import '../models/playlist.dart';
import 'playlist_loader.dart';
import 'xmltv_parser.dart';

/// [playlist]'in EPG adres(ler)ini indirip ayrıştırır. Dosyalar onlarca MB
/// olabildiği için indirme dahil her şey ayrı isolate'te yapılır.
/// Listede EPG adresi yoksa null döner.
Future<Epg?> loadEpg(Playlist playlist) async {
  final urls = (playlist.epgUrl ?? '')
      .split(',')
      .map((u) => u.trim())
      .where((u) => u.startsWith('http://') || u.startsWith('https://'))
      .toList();
  if (urls.isEmpty) return null;
  final ids = {
    for (final c in playlist.channels)
      if (c.tvgId != null) c.tvgId!.toLowerCase(),
  };
  if (ids.isEmpty) return null;
  return _spawn(urls, ids);
}

// Ayrı fonksiyon: closure'ın `playlist`'i yakalayıp isolate'e kopyalamasını
// önler.
Future<Epg> _spawn(List<String> urls, Set<String> ids) =>
    Isolate.run(() => _load(urls, ids));

Future<Epg> _load(List<String> urls, Set<String> ids) async {
  final parts = <Epg>[];
  Object? lastError;
  for (final url in urls) {
    try {
      parts.add(parseXmltv(await _fetch(url), only: ids));
    } on Exception catch (e) {
      // Birden fazla adresten biri çalışmıyorsa diğerleriyle devam et.
      lastError = e;
    }
  }
  if (parts.isEmpty) {
    throw PlaylistException('Yayın akışı alınamadı: $lastError');
  }
  return Epg.combine(parts);
}

Future<String> _fetch(String url) async {
  final response = await http
      .get(Uri.parse(url), headers: const {'User-Agent': userAgent})
      .timeout(const Duration(minutes: 2));
  if (response.statusCode != 200) {
    throw PlaylistException('Sunucu ${response.statusCode} döndürdü.');
  }
  var bytes = response.bodyBytes as List<int>;
  // `.xml.gz` adresleri sıkıştırılmış gelir.
  if (bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
    bytes = gzip.decode(bytes);
  }
  return utf8.decode(bytes, allowMalformed: true);
}

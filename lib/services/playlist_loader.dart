import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/playlist.dart';
import '../models/playlist_source.dart';
import 'm3u_parser.dart';
import 'xtream_client.dart';

/// Bazı sağlayıcılar Dart'ın varsayılan User-Agent'ını reddediyor.
const userAgent = 'Streamlity/0.1';

class PlaylistException implements Exception {
  const PlaylistException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<Playlist> loadSource(PlaylistSource source) => switch (source) {
      M3uSource(:final location) => loadM3u(location),
      final XtreamSource xtream => loadXtream(xtream),
    };

/// [source] bir http(s) URL'si ya da yerel dosya yolu olabilir.
Future<Playlist> loadM3u(String source) async {
  final String content;
  try {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      final response = await http
          .get(Uri.parse(source), headers: const {'User-Agent': userAgent})
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw PlaylistException('Sunucu ${response.statusCode} döndürdü.');
      }
      content = utf8.decode(response.bodyBytes, allowMalformed: true);
    } else {
      final bytes = await File(source).readAsBytes();
      content = utf8.decode(bytes, allowMalformed: true);
    }
  } on PlaylistException {
    rethrow;
  } on Exception catch (e) {
    throw PlaylistException('Liste alınamadı: $e');
  }

  // Büyük listelerde arayüzü kilitlememek için ayrı isolate'te ayrıştır.
  final playlist = await compute(parseM3u, content);
  if (playlist.channels.isEmpty) {
    throw const PlaylistException('Listede kanal bulunamadı.');
  }
  return playlist;
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/playlist.dart';
import '../models/playlist_source.dart';
import 'playlist_loader.dart';

/// Xtream Codes `player_api.php` üzerinden canlı kanalları yükler.
Future<Playlist> loadXtream(XtreamSource source) async {
  final user = await verifyXtream(source);

  final (categories, streams) = await (
    _get(source, const {'action': 'get_live_categories'}),
    _get(source, const {'action': 'get_live_streams'}),
  ).wait;

  final formats = (user['allowed_output_formats'] as List?)?.cast<Object?>();
  final extension =
      formats == null || formats.isEmpty || formats.contains('ts') ? 'ts' : 'm3u8';

  final playlist = await compute(
    (_) => buildXtreamPlaylist(
      source: source,
      categories: categories as List? ?? const [],
      streams: streams as List? ?? const [],
      extension: extension,
      expiresAt: _parseExpiry(user['exp_date']),
    ),
    null,
  );
  if (playlist.channels.isEmpty) {
    throw const PlaylistException('Hesapta canlı kanal bulunamadı.');
  }
  return playlist;
}

/// Giriş bilgilerini ve hesap durumunu denetler; kanal listesini indirmez.
/// Hesap bilgisini (`user_info`) döndürür.
Future<Map<String, dynamic>> verifyXtream(XtreamSource source) async {
  final info = await _get(source, const {});
  final user = info is Map<String, dynamic>
      ? info['user_info'] as Map<String, dynamic>?
      : null;
  if (user == null || '${user['auth']}' != '1') {
    throw const PlaylistException('Kullanıcı adı veya şifre hatalı.');
  }
  final status = '${user['status'] ?? ''}';
  if (status.isNotEmpty && status != 'Active') {
    throw PlaylistException('Hesap kullanılamıyor (durum: $status).');
  }
  return user;
}

/// API yanıtlarını [Playlist]'e dönüştürür. Kanallar kategori sırasıyla,
/// her kategori içinde sağlayıcının verdiği sırayla dizilir.
@visibleForTesting
Playlist buildXtreamPlaylist({
  required XtreamSource source,
  required List<dynamic> categories,
  required List<dynamic> streams,
  required String extension,
  DateTime? expiresAt,
}) {
  final categoryNames = <String, String>{
    for (final c in categories.whereType<Map<String, dynamic>>())
      '${c['category_id']}': '${c['category_name'] ?? ''}'.trim(),
  };

  final byCategory = <String?, List<Channel>>{
    for (final id in categoryNames.keys) id: [],
  };
  final user = Uri.encodeComponent(source.username);
  final pass = Uri.encodeComponent(source.password);

  for (final s in streams.whereType<Map<String, dynamic>>()) {
    final id = s['stream_id'];
    if (id == null) continue;
    final categoryId = s['category_id']?.toString();
    final name = '${s['name'] ?? ''}'.trim();
    final logo = '${s['stream_icon'] ?? ''}'.trim();
    final epgId = '${s['epg_channel_id'] ?? ''}'.trim();
    final group = categoryNames[categoryId];

    byCategory.putIfAbsent(categoryId, () => []).add(Channel(
          name: name.isEmpty ? 'Kanal $id' : name,
          url: '${source.server}/live/$user/$pass/$id.$extension',
          group: (group == null || group.isEmpty) ? null : group,
          logo: logo.isEmpty ? null : logo,
          tvgId: epgId.isEmpty ? null : epgId,
          id: '$id',
        ));
  }

  return Playlist(
    channels: [for (final list in byCategory.values) ...list],
    epgUrl: '${source.server}/xmltv.php?username=$user&password=$pass',
    expiresAt: expiresAt,
  );
}

DateTime? _parseExpiry(Object? value) {
  final seconds = int.tryParse('${value ?? ''}');
  if (seconds == null || seconds <= 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}

const _authFailureCodes = {401, 403, 513};

Future<dynamic> _get(XtreamSource source, Map<String, String> params) async {
  final uri = Uri.parse('${source.server}/player_api.php').replace(
    queryParameters: {
      'username': source.username,
      'password': source.password,
      ...params,
    },
  );
  final http.Response response;
  try {
    response = await http
        .get(uri, headers: const {'User-Agent': userAgent})
        .timeout(const Duration(seconds: 30));
  } on Exception catch (e) {
    throw PlaylistException('Sunucuya bağlanılamadı: $e');
  }
  if (response.statusCode != 200) {
    // Paneller yanlış girişte 200 + auth=0 yerine bu kodları da döndürüyor.
    if (_authFailureCodes.contains(response.statusCode)) {
      throw const PlaylistException('Kullanıcı adı veya şifre hatalı.');
    }
    throw PlaylistException('Sunucu ${response.statusCode} döndürdü.');
  }
  try {
    // Kanal listesi on binlerce kayıt olabilir; arayüzü kilitlememek için
    // JSON'u ayrı isolate'te çöz.
    return await compute(
      (String body) => jsonDecode(body),
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );
  } on FormatException {
    throw const PlaylistException(
        'Sunucu geçerli bir Xtream Codes yanıtı vermedi.');
  }
}

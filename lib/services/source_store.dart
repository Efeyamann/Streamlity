import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/playlist_source.dart';
import '../models/saved_source.dart';

/// Kayıtlı listeleri (Xtream şifreleri dahil) işletim sisteminin güvenli
/// deposunda tutar.
class SourceStore {
  const SourceStore();

  static const _key = 'playlist_sources';

  /// Çoklu liste desteğinden önceki tek kayıt; ilk okumada taşınır.
  static const _legacyKey = 'playlist_source';
  static const _storage = FlutterSecureStorage();

  Future<List<SavedSource>> readAll() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw != null) return decodeSources(raw);
      final legacy = await _storage.read(key: _legacyKey);
      final migrated = migrateLegacySource(legacy);
      if (migrated.isNotEmpty) {
        await writeAll(migrated);
        await _storage.delete(key: _legacyKey);
      }
      return migrated;
    } on Exception {
      // Okunamayan depo: boş başla; kullanıcı listeyi yeniden ekleyebilir.
      return [];
    }
  }

  Future<void> writeAll(List<SavedSource> sources) => _storage.write(
        key: _key,
        value: jsonEncode([for (final s in sources) s.toJson()]),
      );
}

/// Bozuk tek kayıtlar atlanır; biri yüzünden diğer listeler kaybolmasın.
List<SavedSource> decodeSources(String raw) {
  final list = jsonDecode(raw) as List;
  return [
    for (final item in list.whereType<Map<String, dynamic>>())
      ?_tryParse(item),
  ];
}

SavedSource? _tryParse(Map<String, dynamic> json) {
  try {
    return SavedSource.fromJson(json);
  } on Object {
    return null;
  }
}

/// Eski sürümün tek kaynağını ([PlaylistSource] JSON'u) listeye çevirir.
List<SavedSource> migrateLegacySource(String? raw) {
  if (raw == null) return [];
  try {
    final source =
        PlaylistSource.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return [
      SavedSource(
        id: SavedSource.newId(),
        name: SavedSource.defaultName(source),
        source: source,
      ),
    ];
  } on Object {
    return [];
  }
}

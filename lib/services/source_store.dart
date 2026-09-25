import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/playlist_source.dart';

/// Son kullanılan kaynağı (Xtream şifresi dahil) işletim sisteminin güvenli
/// deposunda tutar.
class SourceStore {
  const SourceStore();

  static const _key = 'playlist_source';
  static const _storage = FlutterSecureStorage();

  Future<PlaylistSource?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return PlaylistSource.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Exception {
      // Bozuk ya da okunamayan kayıt: yeniden giriş istemek yeterli.
      return null;
    }
  }

  Future<void> write(PlaylistSource source) =>
      _storage.write(key: _key, value: jsonEncode(source.toJson()));

  Future<void> clear() => _storage.delete(key: _key);
}

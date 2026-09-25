import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/playlist_source.dart';

/// Favori kanalların anahtarlarını ([Channel.key]) kaynak başına saklar.
///
/// Gizli veri değil; uygulama destek klasöründe tek bir JSON dosyasında
/// tutulur. Kaynak kimliği (M3U adresi kimlik bilgisi içerebilir) yalnız
/// özetiyle yazılır.
class FavoritesStore {
  FavoritesStore({Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;
  Map<String, List<String>>? _cache;
  Future<void> _pending = Future.value();

  static String sourceKey(PlaylistSource source) {
    final identity = switch (source) {
      // Şifre değişince favoriler kaybolmasın.
      XtreamSource(:final server, :final username) => 'xtream\n$server\n$username',
      M3uSource(:final location) => 'm3u\n$location',
    };
    return sha1.convert(utf8.encode(identity)).toString();
  }

  Future<File> _file() async =>
      File('${(await _directory()).path}${Platform.pathSeparator}favorites.json');

  Future<Map<String, List<String>>> _readAll() async {
    if (_cache != null) return _cache!;
    try {
      final file = await _file();
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _cache = {
        for (final MapEntry(:key, :value) in json.entries)
          key: (value as List).cast<String>(),
      };
    } on Exception {
      // Dosya yok ya da bozuk: boş başla.
      _cache = {};
    }
    return _cache!;
  }

  Future<Set<String>> read(PlaylistSource source) async =>
      (await _readAll())[sourceKey(source)]?.toSet() ?? {};

  /// Yazmalar sıraya alınır; hızlı art arda değişikliklerde son hal kazanır.
  Future<void> write(PlaylistSource source, Set<String> keys) {
    return _pending = _pending.then((_) async {
      final all = await _readAll();
      if (keys.isEmpty) {
        all.remove(sourceKey(source));
      } else {
        all[sourceKey(source)] = keys.toList();
      }
      final file = await _file();
      await file.parent.create(recursive: true);
      // Yarım kalan yazma dosyayı bozmasın diye önce geçici dosyaya yaz.
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(all), flush: true);
      await temp.rename(file.path);
    }).catchError((Object e) => debugPrint('Favoriler kaydedilemedi: $e'));
  }
}

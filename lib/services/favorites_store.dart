import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/playlist_source.dart';

/// Kanal anahtarı ([Channel.key]) listelerini kaynak başına saklar:
/// favoriler ve son izlenenler, her biri ayrı dosyada.
///
/// Gizli veri değil; uygulama destek klasöründe tek bir JSON dosyasında
/// tutulur. Kaynak kimliği (M3U adresi kimlik bilgisi içerebilir) yalnız
/// özetiyle yazılır.
class FavoritesStore {
  FavoritesStore({
    Future<Directory> Function()? directory,
    this.fileName = 'favorites.json',
  }) : _directory = directory ?? getApplicationSupportDirectory;

  /// Favori kategoriler (kanal paketleri); anahtar grup adı, eklenme
  /// sırasıyla.
  FavoritesStore.groups({Future<Directory> Function()? directory})
      : this(directory: directory, fileName: 'favorite_groups.json');

  /// Film ve dizi kategorilerinden favoriler; anahtar `m:<id>` / `s:<id>`.
  FavoritesStore.vodGroups({Future<Directory> Function()? directory})
      : this(directory: directory, fileName: 'favorite_vod_groups.json');

  /// Son izlenenler; en yenisi başta.
  FavoritesStore.recents({Future<Directory> Function()? directory})
      : this(directory: directory, fileName: 'recents.json');

  /// Kullanıcının kategori sırası (canlı TV'de grup adı, film/dizide
  /// `m:<id>` / `s:<id>`); boşsa sağlayıcının sırası.
  FavoritesStore.categoryOrder({Future<Directory> Function()? directory})
      : this(directory: directory, fileName: 'category_order.json');

  /// Gizlenen kategoriler; anahtarlar [FavoritesStore.categoryOrder] ile
  /// aynı.
  FavoritesStore.hiddenCategories({Future<Directory> Function()? directory})
      : this(directory: directory, fileName: 'hidden_categories.json');

  final Future<Directory> Function() _directory;
  final String fileName;
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
      File('${(await _directory()).path}${Platform.pathSeparator}$fileName');

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
      (await readList(source)).toSet();

  Future<void> write(PlaylistSource source, Set<String> keys) =>
      writeList(source, keys.toList());

  /// Sırası korunan liste.
  Future<List<String>> readList(PlaylistSource source) async =>
      (await _readAll())[sourceKey(source)] ?? [];

  /// Yazmalar sıraya alınır; hızlı art arda değişikliklerde son hal kazanır.
  Future<void> writeList(PlaylistSource source, List<String> keys) {
    return _pending = _pending.then((_) async {
      final all = await _readAll();
      if (keys.isEmpty) {
        all.remove(sourceKey(source));
      } else {
        all[sourceKey(source)] = [...keys];
      }
      final file = await _file();
      await file.parent.create(recursive: true);
      // Yarım kalan yazma dosyayı bozmasın diye önce geçici dosyaya yaz.
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(all), flush: true);
      await temp.rename(file.path);
    }).catchError((Object e) => debugPrint('$fileName kaydedilemedi: $e'));
  }
}

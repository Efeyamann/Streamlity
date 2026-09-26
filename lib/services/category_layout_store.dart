import 'dart:io';

import '../models/category_layout.dart';
import '../models/playlist_source.dart';
import 'favorites_store.dart';

/// Kategori türü: kayıt anahtarının öneki.
enum CategoryKind {
  live('l:'),
  movies('m:'),
  series('s:');

  const CategoryKind(this.prefix);
  final String prefix;
}

/// Kategori sırası, gizlileri ve kilitlileri kaynak ve tür başına saklar. Dosyada
/// anahtarlar öneklidir (`l:TR| SPOR`, `m:12`); dışarıya öneksiz verilir.
class CategoryLayoutStore {
  CategoryLayoutStore({Future<Directory> Function()? directory})
      : _order = FavoritesStore.categoryOrder(directory: directory),
        _hidden = FavoritesStore.hiddenCategories(directory: directory),
        _locked = FavoritesStore.lockedCategories(directory: directory);

  final FavoritesStore _order;
  final FavoritesStore _hidden;
  final FavoritesStore _locked;

  static List<String> _own(List<String> keys, CategoryKind kind) => [
        for (final k in keys)
          if (k.startsWith(kind.prefix)) k.substring(kind.prefix.length),
      ];

  Future<CategoryLayout> read(PlaylistSource source, CategoryKind kind) async {
    final order = await _order.readList(source);
    final hidden = await _hidden.readList(source);
    final locked = await _locked.readList(source);
    return CategoryLayout(
      order: _own(order, kind),
      hidden: _own(hidden, kind).toSet(),
      locked: _own(locked, kind).toSet(),
    );
  }

  Future<void> write(
      PlaylistSource source, CategoryKind kind, CategoryLayout layout) async {
    List<String> merge(List<String> all, Iterable<String> mine) => [
          for (final k in all)
            if (!k.startsWith(kind.prefix)) k,
          for (final k in mine) '${kind.prefix}$k',
        ];
    await _order.writeList(
        source, merge(await _order.readList(source), layout.order));
    await _hidden.writeList(
        source, merge(await _hidden.readList(source), layout.hidden));
    await _locked.writeList(
        source, merge(await _locked.readList(source), layout.locked));
  }
}

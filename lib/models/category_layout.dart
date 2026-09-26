/// Kullanıcının kategori düzeni: kendi sırası ve gizledikleri. Anahtar
/// canlı TV'de grup adı, film/dizide `m:<id>` / `s:<id>`.
class CategoryLayout {
  const CategoryLayout({this.order = const [], this.hidden = const {}});

  static const empty = CategoryLayout();

  /// Kullanıcının taşıdığı kategoriler bu sırayla başa gelir; listede
  /// olmayanlar sağlayıcının sırasıyla ardından gelir.
  final List<String> order;
  final Set<String> hidden;

  bool get isEmpty => order.isEmpty && hidden.isEmpty;

  bool isHidden(String key) => hidden.contains(key);

  /// [items]'ı kullanıcının sırasına dizer. Gizliler dahil; süzmek için
  /// [visible].
  List<T> arrange<T>(Iterable<T> items, String Function(T) keyOf) {
    final byKey = {for (final i in items) keyOf(i): i};
    final placed = <String>{};
    return [
      for (final k in order)
        if (byKey[k] case final item? when placed.add(k)) item,
      for (final i in items)
        if (!placed.contains(keyOf(i))) i,
    ];
  }

  /// Sıralanmış ve gizlileri çıkarılmış liste.
  List<T> visible<T>(Iterable<T> items, String Function(T) keyOf) => [
        for (final i in arrange(items, keyOf))
          if (!hidden.contains(keyOf(i))) i,
      ];
}

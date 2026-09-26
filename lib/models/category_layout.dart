/// Kullanıcının kategori düzeni: kendi sırası, gizledikleri ve PIN'le
/// kilitledikleri. Anahtar canlı TV'de grup adı, film/dizide kategori
/// kimliği.
class CategoryLayout {
  const CategoryLayout({
    this.order = const [],
    this.hidden = const {},
    this.locked = const {},
  });

  static const empty = CategoryLayout();

  /// Kullanıcının taşıdığı kategoriler bu sırayla başa gelir; listede
  /// olmayanlar sağlayıcının sırasıyla ardından gelir.
  final List<String> order;
  final Set<String> hidden;

  /// Açmak için PIN istenen kategoriler. Listede kilit simgesiyle görünür;
  /// kilit açık değilken kanalları "Tümü"nde, aramada ve ana sayfada çıkmaz.
  final Set<String> locked;

  bool get isEmpty => order.isEmpty && hidden.isEmpty && locked.isEmpty;

  bool isHidden(String key) => hidden.contains(key);

  bool isLocked(String key) => locked.contains(key);

  /// Toplu görünümlerde (tümü, arama, ana sayfa) öğeleri gösterilmeyen
  /// kategoriler: gizliler ve kilitler kapalıysa kilitliler.
  Set<String> excluded({required bool locksActive}) =>
      locksActive && locked.isNotEmpty ? {...hidden, ...locked} : hidden;

  CategoryLayout withoutLocks() =>
      CategoryLayout(order: order, hidden: hidden);

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

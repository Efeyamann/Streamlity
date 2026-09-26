import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/category_layout.dart';
import '../models/playlist.dart' show searchKey;
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';

/// Düzenleyicideki kategori: kayıt anahtarı, görünen ad, öğe sayısı.
typedef CategoryEntry = ({String key, String label, int? count});

/// Kategorileri sıralama ve gizleme penceresi. Kaydedilirse yeni düzen,
/// vazgeçilirse null döner.
Future<CategoryLayout?> showCategoryEditor(
  BuildContext context, {
  required List<CategoryEntry> entries,
  required CategoryLayout layout,
}) =>
    showDialog<CategoryLayout>(
      context: context,
      builder: (_) => _CategoryEditor(entries: entries, layout: layout),
    );

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({required this.entries, required this.layout});

  final List<CategoryEntry> entries;
  final CategoryLayout layout;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late final Map<String, CategoryEntry> _byKey = {
    for (final e in widget.entries) e.key: e,
  };
  late List<String> _order =
      widget.layout.arrange(widget.entries, (e) => e.key).map((e) => e.key).toList();
  late Set<String> _hidden = {
    for (final k in widget.layout.hidden)
      if (_byKey.containsKey(k)) k,
  };
  String _query = '';

  List<String> get _providerOrder => [for (final e in widget.entries) e.key];

  List<String> _matching() {
    final q = searchKey(_query.trim());
    if (q.isEmpty) return _order;
    return [
      for (final k in _order)
        if (searchKey(_byKey[k]!.label).contains(q)) k,
    ];
  }

  void _toggle(String key) => setState(() {
        _hidden = {..._hidden};
        if (!_hidden.remove(key)) _hidden.add(key);
      });

  void _moveToTop(String key) => setState(() {
        _order = [key, for (final k in _order) if (k != key) k];
      });

  void _setAll(List<String> keys, {required bool hidden}) => setState(() {
        _hidden = hidden ? {..._hidden, ...keys} : ({..._hidden}..removeAll(keys));
      });

  void _reset() => setState(() {
        _order = _providerOrder;
        _hidden = {};
      });

  void _save() {
    // Sağlayıcının sırasıyla aynıysa sıra saklanmaz; yeni kategoriler
    // eklenince kendi yerlerine düşsünler.
    final same = _order.length == _providerOrder.length &&
        Iterable.generate(_order.length)
            .every((i) => _order[i] == _providerOrder[i]);
    Navigator.of(context).pop(CategoryLayout(
      order: same ? const [] : _order,
      hidden: _hidden,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    final filtering = _query.trim().isNotEmpty;
    final matching = _matching();
    final matchingHidden = matching.where(_hidden.contains).length;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  Space.lg, Space.md, Space.xs, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.editCategories,
                            style: theme.textTheme.titleLarge),
                        Text(l.editCategoriesHint,
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l.close,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.md, Space.lg, Space.xs),
              child: SearchField(
                hint: l.searchCategories,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: Row(
                children: [
                  Text(l.hiddenCount(_hidden.length),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: c.fgMuted)),
                  const Spacer(),
                  if (filtering && matching.isNotEmpty) ...[
                    if (matchingHidden < matching.length)
                      TextButton.icon(
                        onPressed: () => _setAll(matching, hidden: true),
                        icon: const Icon(Icons.visibility_off_outlined,
                            size: IconSizes.sm),
                        label: Text(l.hideMatching(matching.length)),
                      ),
                    if (matchingHidden > 0)
                      TextButton.icon(
                        onPressed: () => _setAll(matching, hidden: false),
                        icon: const Icon(Icons.visibility_outlined,
                            size: IconSizes.sm),
                        label: Text(l.showMatching(matchingHidden)),
                      ),
                  ],
                ],
              ),
            ),
            Divider(color: c.border),
            Flexible(
              child: filtering
                  ? ListView.builder(
                      itemCount: matching.length,
                      itemBuilder: (context, i) =>
                          _row(matching[i], draggable: false, index: i),
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: _order.length,
                      onReorderItem: (from, to) => setState(() {
                        final list = [..._order];
                        list.insert(to, list.removeAt(from));
                        _order = list;
                      }),
                      itemBuilder: (context, i) =>
                          _row(_order[i], draggable: true, index: i),
                    ),
            ),
            Divider(color: c.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Space.md, Space.xs, Space.md, Space.md),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt, size: IconSizes.md),
                    label: Text(l.reset),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.cancel),
                  ),
                  const SizedBox(width: Space.xs),
                  FilledButton(onPressed: _save, child: Text(l.save)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String key, {required bool draggable, required int index}) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    final entry = _byKey[key]!;
    final hidden = _hidden.contains(key);
    return Material(
      key: ValueKey(key),
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: Space.sm, end: Space.sm),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              if (draggable)
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Tooltip(
                      message: l.dragToReorder,
                      child: Padding(
                        padding: const EdgeInsets.all(Space.xs),
                        child: Icon(Icons.drag_indicator,
                            size: IconSizes.md, color: c.fgSubtle),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: Space.xs),
              const SizedBox(width: Space.xxs),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hidden ? c.fgSubtle : c.fg,
                    decoration: hidden ? TextDecoration.lineThrough : null,
                    decorationColor: c.fgSubtle,
                  ),
                ),
              ),
              if (entry.count case final count?)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.xs),
                  child: Text(l.count(count),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: c.fgMuted)),
                ),
              IconButton(
                tooltip: l.moveToTop,
                visualDensity: VisualDensity.compact,
                iconSize: IconSizes.md,
                icon: const Icon(Icons.vertical_align_top),
                onPressed: _order.first == key ? null : () => _moveToTop(key),
              ),
              IconButton(
                tooltip: hidden ? l.showCategory : l.hideCategory,
                visualDensity: VisualDensity.compact,
                iconSize: IconSizes.md,
                color: hidden ? c.fgSubtle : c.fg,
                icon: Icon(hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => _toggle(key),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

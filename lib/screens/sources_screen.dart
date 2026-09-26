import 'package:flutter/material.dart';

import '../models/playlist_source.dart';
import '../models/saved_source.dart';
import '../services/favorites_store.dart';
import '../services/source_store.dart';
import '../l10n/l10n.dart';
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';
import '../ui/widgets/logo_mark.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';
import 'source_dialog.dart';

/// Ana sayfa: kayıtlı listeler. Buradan liste eklenir, düzenlenir, silinir
/// ve açılır.
class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  final _store = const SourceStore();
  List<SavedSource>? _sources;

  @override
  void initState() {
    super.initState();
    _store.readAll().then((sources) {
      if (mounted) setState(() => _sources = sources);
    });
  }

  Future<void> _save(List<SavedSource> sources) async {
    setState(() => _sources = sources);
    await _store.writeAll(sources);
  }

  /// [updated]'ı aynı kimlikli kaydın yerine koyar.
  Future<void> _replace(SavedSource updated) => _save([
        for (final s in _sources ?? const <SavedSource>[])
          s.id == updated.id ? updated : s,
      ]);

  Future<void> _add() async {
    final added = await showSourceDialog(context, existing: _sources ?? []);
    if (added == null || !mounted) return;
    await _save([...?_sources, added]);
    if (mounted) _open(added);
  }

  Future<void> _edit(SavedSource source) async {
    final edited = await showSourceDialog(context,
        initial: source, existing: _sources ?? []);
    if (edited != null) await _replace(edited);
  }

  Future<void> _delete(SavedSource source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteListTitle),
        content: Text(context.l10n.deleteListMessage(source.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(context).danger,
              foregroundColor: AppColors.of(context).onAccent,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Aynı kaynak başka bir kayıtta da duruyorsa favorileri ortaktır.
    final stillUsed = (_sources ?? const []).any((s) =>
        s.id != source.id &&
        FavoritesStore.sourceKey(s.source) ==
            FavoritesStore.sourceKey(source.source));
    await _save([
      for (final s in _sources ?? const <SavedSource>[])
        if (s.id != source.id) s,
    ]);
    if (!stillUsed) {
      await FavoritesStore().write(source.source, {});
      await FavoritesStore.recents().writeList(source.source, []);
      await FavoritesStore.groups().writeList(source.source, []);
      await FavoritesStore.vodGroups().writeList(source.source, []);
      await FavoritesStore.categoryOrder().writeList(source.source, []);
      await FavoritesStore.hiddenCategories().writeList(source.source, []);
      await FavoritesStore.lockedCategories().writeList(source.source, []);
    }
  }

  void _open(SavedSource source) {
    final opened = source.copyWith(lastOpenedAt: DateTime.now());
    _replace(opened);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PlaylistScreen(
        saved: opened,
        onLoaded: (channelCount, expiresAt) {
          // Liste açıkken kayıt düzenlenmiş olabilir; güncelini kullan.
          final current =
              (_sources ?? const []).where((s) => s.id == opened.id).firstOrNull;
          if (current == null) return;
          _replace(current.copyWith(
            channelCount: channelCount,
            expiresAt: expiresAt,
          ));
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final sources = _sources;
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    return Scaffold(
      body: sources == null
          ? const Center(child: CircularProgressIndicator())
          : sources.isEmpty
              ? _Welcome(onAdd: _add)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Space.xl, Space.xl, Space.xl, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const LogoMark(size: 44),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.appTitle,
                                    style: theme.textTheme.headlineSmall),
                                Text(
                                  l.listCount(sources.length),
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: c.fgMuted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l.sectionSettings,
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () => openSettings(context),
                          ),
                          const SizedBox(width: Space.xs),
                          FilledButton.icon(
                            onPressed: _add,
                            icon: const Icon(Icons.add),
                            label: Text(l.addList),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xl),
                      SectionHeader(l.yourLists,
                          padding: const EdgeInsets.only(bottom: Space.sm)),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: Space.xl),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 380,
                            mainAxisExtent: 150,
                            crossAxisSpacing: Space.md,
                            mainAxisSpacing: Space.md,
                          ),
                          itemCount: sources.length,
                          itemBuilder: (context, i) => _SourceCard(
                            source: sources[i],
                            onOpen: () => _open(sources[i]),
                            onEdit: () => _edit(sources[i]),
                            onDelete: () => _delete(sources[i]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    Widget kind(IconData icon, String title, String text) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: Radii.lgAll,
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: c.accent),
                const SizedBox(height: Space.xs),
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(text, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        );
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoMark(size: 72),
              const SizedBox(height: Space.lg),
              Text(l.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: Space.xs),
              Text(
                l.welcomeMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: c.fgMuted),
              ),
              const SizedBox(height: Space.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kind(Icons.dns_rounded, 'Xtream Codes', l.xtreamDescription),
                  const SizedBox(width: Space.sm),
                  kind(Icons.playlist_play_rounded, 'M3U', l.m3uDescription),
                ],
              ),
              const SizedBox(height: Space.lg),
              FilledButton.icon(
                autofocus: true,
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(l.addList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceCard extends StatefulWidget {
  const _SourceCard({
    required this.source,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedSource source;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static String _host(String location) {
    final uri = Uri.tryParse(location);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) return uri.host;
    return location.split(RegExp(r'[\\/]')).last;
  }

  @override
  State<_SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<_SourceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final l = context.l10n;
    final source = widget.source;
    // Ad zaten sunucu adıysa alt satırda tekrarlama.
    String host(String location) {
      final h = _SourceCard._host(location);
      return h == source.name ? '' : h;
    }

    final (icon, parts) = switch (source.source) {
      XtreamSource(:final server) =>
        (Icons.dns_rounded, ['Xtream', host(server)]),
      M3uSource(:final location) =>
        (Icons.playlist_play_rounded, ['M3U', host(location)]),
    };
    final subtitle = parts.where((p) => p.isNotEmpty).join(' · ');
    final expiresAt = source.expiresAt;
    final now = DateTime.now();
    final expired = expiresAt != null && expiresAt.isBefore(now);
    final expiringSoon = expiresAt != null &&
        !expired &&
        expiresAt.difference(now) < const Duration(days: 7);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onOpen,
          borderRadius: Radii.lgAll,
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: motion.fast,
            padding: const EdgeInsetsDirectional.fromSTEB(
                Space.md, Space.md, Space.xs, Space.md),
            decoration: BoxDecoration(
              borderRadius: Radii.lgAll,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hovered
                    ? [c.accent.withValues(alpha: 0.16), c.surfaceRaised]
                    : [c.surfaceRaised, c.surface],
              ),
              border: Border.all(
                  color: _hovered
                      ? c.accent.withValues(alpha: 0.5)
                      : c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.accent.withValues(alpha: 0.14),
                        borderRadius: Radii.mdAll,
                      ),
                      child: Icon(icon, color: c.accent),
                    ),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(source.name,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(subtitle,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    MenuAnchor(
                      menuChildren: [
                        MenuItemButton(
                          leadingIcon: const Icon(Icons.edit_outlined,
                              size: IconSizes.md),
                          onPressed: widget.onEdit,
                          child: Text(l.edit),
                        ),
                        MenuItemButton(
                          leadingIcon: Icon(Icons.delete_outline,
                              size: IconSizes.md, color: c.danger),
                          onPressed: widget.onDelete,
                          child:
                              Text(l.delete, style: TextStyle(color: c.danger)),
                        ),
                      ],
                      builder: (context, controller, _) => IconButton(
                        tooltip: l.options,
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => controller.isOpen
                            ? controller.close()
                            : controller.open(),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: Space.xs,
                        runSpacing: 6,
                        children: [
                          if (source.channelCount case final count?)
                            _Tag(
                                icon: Icons.live_tv_outlined,
                                text: l.channelCount(count)),
                          if (expiresAt != null)
                            _Tag(
                              icon: Icons.event_outlined,
                              text: expired
                                  ? l.expired
                                  : l.expiresOn(l.date(expiresAt)),
                              color: expired
                                  ? c.danger
                                  : expiringSoon
                                      ? c.warning
                                      : null,
                            ),
                          if (source.channelCount == null)
                            _Tag(
                                icon: Icons.play_circle_outline,
                                text: l.notOpenedYet),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: motion.fast,
                      opacity: _hovered ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: Space.xs),
                        child: Icon(Icons.arrow_forward_rounded,
                            color: c.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = this.color ?? c.fgMuted;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.muted,
        borderRadius: Radii.smAll,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(text,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

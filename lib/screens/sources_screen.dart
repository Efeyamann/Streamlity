import 'package:flutter/material.dart';

import '../models/playlist_source.dart';
import '../models/saved_source.dart';
import '../services/favorites_store.dart';
import '../services/source_store.dart';
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';
import '../ui/widgets/logo_mark.dart';
import 'playlist_screen.dart';
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
        title: const Text('Liste silinsin mi?'),
        content: Text(
            '"${source.name}", favori paketleri ve son izlenenleri '
            'silinecek. '
            'Sağlayıcıdaki hesabın etkilenmez.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(context).danger,
              foregroundColor: AppColors.of(context).onAccent,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
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
                                Text('Streamlity',
                                    style: theme.textTheme.headlineSmall),
                                Text(
                                  sources.length == 1
                                      ? 'Listen'
                                      : '${sources.length} liste',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: c.fgMuted),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _add,
                            icon: const Icon(Icons.add),
                            label: const Text('Liste ekle'),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xl),
                      const SectionHeader('Listelerin',
                          padding: EdgeInsets.only(bottom: Space.sm)),
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
              Text("Streamlity'ye hoş geldin",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: Space.xs),
              Text(
                'Başlamak için bir liste ekle. İstediğin kadar liste ekleyip '
                'aralarında geçiş yapabilirsin.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: c.fgMuted),
              ),
              const SizedBox(height: Space.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kind(Icons.dns_rounded, 'Xtream Codes',
                      'Sunucu, kullanıcı adı ve şifre. Canlı TV, film, dizi.'),
                  const SizedBox(width: Space.sm),
                  kind(Icons.playlist_play_rounded, 'M3U',
                      'Bir liste adresi ya da bilgisayardaki dosya.'),
                ],
              ),
              const SizedBox(height: Space.lg),
              FilledButton.icon(
                autofocus: true,
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Liste ekle'),
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
            padding: const EdgeInsets.fromLTRB(
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
                          child: const Text('Düzenle'),
                        ),
                        MenuItemButton(
                          leadingIcon: Icon(Icons.delete_outline,
                              size: IconSizes.md, color: c.danger),
                          onPressed: widget.onDelete,
                          child:
                              Text('Sil', style: TextStyle(color: c.danger)),
                        ),
                      ],
                      builder: (context, controller, _) => IconButton(
                        tooltip: 'Seçenekler',
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
                                text: '${formatCount(count)} kanal'),
                          if (expiresAt != null)
                            _Tag(
                              icon: Icons.event_outlined,
                              text: expired
                                  ? 'Süresi doldu'
                                  : 'Bitiş ${formatDate(expiresAt)}',
                              color: expired
                                  ? c.danger
                                  : expiringSoon
                                      ? c.warning
                                      : null,
                            ),
                          if (source.channelCount == null)
                            const _Tag(
                                icon: Icons.play_circle_outline,
                                text: 'Henüz açılmadı'),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: motion.fast,
                      opacity: _hovered ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(right: Space.xs),
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
        color: const Color(0x0FFFFFFF),
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

String formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';

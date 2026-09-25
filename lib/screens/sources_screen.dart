import 'package:flutter/material.dart';

import '../models/playlist_source.dart';
import '../models/saved_source.dart';
import '../services/favorites_store.dart';
import '../services/source_store.dart';
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
            '"${source.name}" ve bu listedeki favoriler silinecek. '
            'Sağlayıcıdaki hesabın etkilenmez.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
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
    if (!stillUsed) await FavoritesStore().write(source.source, {});
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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: sources == null
            ? const Center(child: CircularProgressIndicator())
            : sources.isEmpty
                ? _Welcome(onAdd: _add)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Streamlity',
                                      style: theme.textTheme.headlineMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Listelerin',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant),
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
                        const SizedBox(height: 24),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 32),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              mainAxisExtent: 128,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
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
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.live_tv_rounded,
                size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text('Streamlity\'ye hoş geldin',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Başlamak için Xtream Codes hesabını ya da M3U listeni ekle. '
              'İstediğin kadar liste ekleyip aralarında geçiş yapabilirsin.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Liste ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Ad zaten sunucu adıysa alt satırda tekrarlama.
    String host(String location) {
      final h = _host(location);
      return h == source.name ? '' : h;
    }

    final (icon, parts) = switch (source.source) {
      XtreamSource(:final server, :final username) =>
        (Icons.dns_rounded, ['Xtream', host(server), username]),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: Icon(icon),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<VoidCallback>(
                    tooltip: 'Seçenekler',
                    onSelected: (action) => action(),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: onEdit,
                        child: const ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Düzenle'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: onDelete,
                        child: ListTile(
                          leading:
                              Icon(Icons.delete_outline, color: scheme.error),
                          title: Text('Sil',
                              style: TextStyle(color: scheme.error)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (source.channelCount case final count?)
                    _Tag(
                        icon: Icons.tv_rounded,
                        text: '${formatCount(count)} kanal'),
                  if (expiresAt != null)
                    _Tag(
                      icon: Icons.event_rounded,
                      text: expired
                          ? 'Süresi doldu'
                          : 'Bitiş ${formatDate(expiresAt)}',
                      color: expired || expiringSoon ? scheme.error : null,
                    ),
                  if (source.channelCount == null)
                    const _Tag(
                        icon: Icons.play_circle_outline, text: 'Henüz açılmadı'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _host(String location) {
    final uri = Uri.tryParse(location);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) return uri.host;
    return location.split(RegExp(r'[\\/]')).last;
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(text,
                style: theme.textTheme.labelSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

/// 56423 -> "56.423"
String formatCount(int n) {
  final s = '$n';
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write('.');
    out.write(s[i]);
  }
  return out.toString();
}

String formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';

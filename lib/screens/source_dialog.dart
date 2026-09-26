import 'package:flutter/material.dart';

import '../models/playlist_source.dart';
import '../models/saved_source.dart';
import '../services/favorites_store.dart';
import '../services/playlist_loader.dart';
import '../services/xtream_client.dart';
import '../l10n/l10n.dart';
import '../ui/tokens.dart';

/// Liste ekleme ya da düzenleme penceresi. Kaydedilen listeyi döndürür;
/// vazgeçilirse null. [existing] içindeki bir listeyle aynı kaynak yeniden
/// eklenemez.
Future<SavedSource?> showSourceDialog(
  BuildContext context, {
  SavedSource? initial,
  List<SavedSource> existing = const [],
}) =>
    showDialog<SavedSource>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SourceDialog(initial: initial, existing: existing),
    );

class _SourceDialog extends StatefulWidget {
  const _SourceDialog({required this.initial, required this.existing});

  final SavedSource? initial;
  final List<SavedSource> existing;

  @override
  State<_SourceDialog> createState() => _SourceDialogState();
}

class _SourceDialogState extends State<_SourceDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _name = TextEditingController();
  final _server = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _m3u = TextEditingController();
  bool _showPassword = false;
  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final source = initial?.source;
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: source is M3uSource ? 1 : 0,
    )..addListener(() => setState(() => _error = null));
    _name.text = initial?.name ?? '';
    switch (source) {
      case XtreamSource():
        _server.text = source.server;
        _username.text = source.username;
        _password.text = source.password;
      case M3uSource():
        _m3u.text = source.location;
      case null:
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_name, _server, _username, _password, _m3u]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Sağlayıcının verdiği `get.php?username=..&password=..` linki sunucu
  /// alanına yapıştırılırsa alanları ondan doldurur.
  void _onServerChanged(String value) {
    final parsed = XtreamSource.tryParseLink(value);
    if (parsed == null) return;
    setState(() {
      // İmleci sona koy; aksi halde yapıştırılan metin seçili kalıyor.
      _server.value = TextEditingValue(
        text: parsed.server,
        selection: TextSelection.collapsed(offset: parsed.server.length),
      );
      _username.text = parsed.username;
      _password.text = parsed.password;
    });
  }

  PlaylistSource? _source() {
    if (_tabs.index == 0) {
      if (_server.text.trim().isEmpty || _username.text.trim().isEmpty) {
        return null;
      }
      return XtreamSource(
        server: _server.text,
        username: _username.text.trim(),
        password: _password.text,
      );
    }
    final location = _m3u.text.trim();
    return location.isEmpty ? null : M3uSource(location);
  }

  Future<void> _submit() async {
    if (_checking) return;
    final source = _source();
    if (source == null) {
      setState(() => _error = _tabs.index == 0
          ? context.l10n.errServerAndUserRequired
          : context.l10n.errLocationRequired);
      return;
    }
    // Aynı sunucu + kullanıcı adı (ya da aynı M3U adresi) aynı listedir.
    final key = FavoritesStore.sourceKey(source);
    final duplicate = widget.existing
        .where((s) =>
            s.id != widget.initial?.id &&
            FavoritesStore.sourceKey(s.source) == key)
        .firstOrNull;
    if (duplicate != null) {
      setState(() => _error = context.l10n.errDuplicateList(duplicate.name));
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      // Yanlış şifre, liste eklenmeden yakalansın. M3U'yu doğrulamak tüm
      // listeyi indirmek demek; o yüzden açılışa bırakılır.
      if (source is XtreamSource) await verifyXtream(source);
    } on PlaylistException catch (e) {
      if (mounted) {
        setState(() {
          _checking = false;
          _error = context.l10n.error(e);
        });
      }
      return;
    }
    if (!mounted) return;
    final name = _name.text.trim();
    final initial = widget.initial;
    Navigator.of(context).pop(
      initial == null
          ? SavedSource(
              id: SavedSource.newId(),
              name: name.isEmpty ? SavedSource.defaultName(source) : name,
              source: source,
            )
          : initial.copyWith(
              name: name.isEmpty ? SavedSource.defaultName(source) : name,
              source: source,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !_checking;
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.initial == null ? l.addList : l.editList),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: _tabs,
              tabs: const [Tab(text: 'Xtream Codes'), Tab(text: 'M3U')],
            ),
            const SizedBox(height: Space.lg),
            TextField(
              controller: _name,
              enabled: enabled,
              decoration: InputDecoration(
                labelText: l.listNameOptional,
                prefixIcon: const Icon(Icons.label_outline),
                hintText: l.listNameHint,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _tabs,
              builder: (context, _) => _tabs.index == 0
                  ? _xtreamFields(enabled)
                  : _m3uFields(enabled),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: Space.sm),
              Container(
                padding: const EdgeInsets.all(Space.sm),
                decoration: BoxDecoration(
                  color: AppColors.of(context).danger.withValues(alpha: 0.12),
                  borderRadius: Radii.mdAll,
                  border: Border.all(
                      color:
                          AppColors.of(context).danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline,
                        size: IconSizes.md,
                        color: AppColors.of(context).danger),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: Text(error,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.of(context).fg)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: enabled ? () => Navigator.of(context).pop() : null,
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: enabled ? _submit : null,
          child: _checking
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.initial == null ? l.add : l.save),
        ),
      ],
    );
  }

  Widget _xtreamFields(bool enabled) {
    final l = context.l10n;
    return Column(
      children: [
        TextField(
          controller: _server,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: l.serverAddress,
            prefixIcon: const Icon(Icons.dns_outlined),
            hintText: l.serverAddressHint,
          ),
          onChanged: _onServerChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _username,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: l.username,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          enabled: enabled,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: l.password,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: _showPassword ? l.hidePassword : l.showPassword,
              icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }

  Widget _m3uFields(bool enabled) {
    return TextField(
      controller: _m3u,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: context.l10n.m3uLocation,
        prefixIcon: const Icon(Icons.link),
      ),
      onSubmitted: (_) => _submit(),
    );
  }
}

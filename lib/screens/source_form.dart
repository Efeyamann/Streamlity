import 'package:flutter/material.dart';

import '../models/playlist_source.dart';

/// Xtream Codes girişi ya da M3U listesi seçimi.
class SourceForm extends StatefulWidget {
  const SourceForm({
    super.key,
    required this.initial,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  /// Formun önceden doldurulacağı kaynak (ör. açılışta yüklenemeyen kayıt).
  final PlaylistSource? initial;
  final bool loading;
  final String? error;
  final ValueChanged<PlaylistSource> onSubmit;

  @override
  State<SourceForm> createState() => _SourceFormState();
}

class _SourceFormState extends State<SourceForm>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _server = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _m3u = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: initial is M3uSource ? 1 : 0,
    );
    switch (initial) {
      case XtreamSource():
        _server.text = initial.server;
        _username.text = initial.username;
        _password.text = initial.password;
      case M3uSource():
        _m3u.text = initial.location;
      case null:
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_server, _username, _password, _m3u]) {
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

  void _submit() {
    if (widget.loading) return;
    if (_tabs.index == 0) {
      if (_server.text.trim().isEmpty || _username.text.trim().isEmpty) return;
      widget.onSubmit(XtreamSource(
        server: _server.text,
        username: _username.text.trim(),
        password: _password.text,
      ));
    } else {
      final location = _m3u.text.trim();
      if (location.isEmpty) return;
      widget.onSubmit(M3uSource(location));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.loading;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Streamlity',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabs,
                tabs: const [Tab(text: 'Xtream Codes'), Tab(text: 'M3U')],
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _tabs,
                builder: (context, _) => _tabs.index == 0
                    ? _xtreamFields(enabled)
                    : _m3uFields(enabled),
              ),
              if (widget.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: enabled ? _submit : null,
                child: widget.loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Yükle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _xtreamFields(bool enabled) {
    return Column(
      children: [
        TextField(
          controller: _server,
          enabled: enabled,
          decoration: const InputDecoration(
            labelText: 'Sunucu adresi',
            hintText: 'http://sunucu:8080 veya sağlayıcının M3U linki',
            border: OutlineInputBorder(),
          ),
          onChanged: _onServerChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _username,
          enabled: enabled,
          decoration: const InputDecoration(
            labelText: 'Kullanıcı adı',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          enabled: enabled,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Şifre',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
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
      decoration: const InputDecoration(
        labelText: 'M3U listesi (URL veya dosya yolu)',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _submit(),
    );
  }
}

/// Kanal listesinin nereden geldiği. Cihazda saklanır ve açılışta yeniden
/// yüklenir.
sealed class PlaylistSource {
  const PlaylistSource();

  Map<String, String> toJson();

  static PlaylistSource fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'm3u' => M3uSource(json['location'] as String),
        'xtream' => XtreamSource(
            server: json['server'] as String,
            username: json['username'] as String,
            password: json['password'] as String,
          ),
        final type => throw FormatException('Bilinmeyen kaynak türü: $type'),
      };
}

class M3uSource extends PlaylistSource {
  const M3uSource(this.location);

  /// http(s) URL'si ya da yerel dosya yolu.
  final String location;

  @override
  Map<String, String> toJson() => {'type': 'm3u', 'location': location};
}

class XtreamSource extends PlaylistSource {
  XtreamSource({
    required String server,
    required this.username,
    required this.password,
  }) : server = normalizeServer(server);

  /// Şema, host ve varsa port; sonda eğik çizgi yok. Örn. `http://host:8080`.
  final String server;
  final String username;
  final String password;

  @override
  Map<String, String> toJson() => {
        'type': 'xtream',
        'server': server,
        'username': username,
        'password': password,
      };

  /// Kullanıcının girdiği adresten yalnız şema, host ve portu bırakır;
  /// şema yoksa `http://` varsayar.
  static String normalizeServer(String input) {
    var s = input.trim();
    if (!s.contains('://')) s = 'http://$s';
    final uri = Uri.parse(s);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  /// Sağlayıcıların verdiği `get.php?username=..&password=..` gibi bir
  /// linkten giriş bilgilerini çıkarır; link bu biçimde değilse null.
  static XtreamSource? tryParseLink(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    final username = uri.queryParameters['username'];
    final password = uri.queryParameters['password'];
    if (username == null || username.isEmpty || password == null) return null;
    return XtreamSource(
      server: link,
      username: username,
      password: password,
    );
  }
}

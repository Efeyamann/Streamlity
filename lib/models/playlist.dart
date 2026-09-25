/// Bir oynatma listesindeki tek kanal.
class Channel {
  const Channel({
    required this.name,
    required this.url,
    this.group,
    this.logo,
    this.tvgId,
  });

  final String name;
  final String url;
  final String? group;
  final String? logo;

  /// EPG eşleştirmesi için kullanılan kimlik (`tvg-id`).
  final String? tvgId;
}

class Playlist {
  Playlist({required this.channels, this.epgUrl});

  static const ungrouped = 'Grupsuz';

  final List<Channel> channels;

  /// Başlıktaki `url-tvg` / `x-tvg-url` değeri.
  final String? epgUrl;

  /// Gruplar, listede ilk göründükleri sırayla.
  late final List<String> groups = {
    for (final c in channels) c.group ?? ungrouped,
  }.toList();
}

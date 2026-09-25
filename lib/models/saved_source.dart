import 'playlist_source.dart';

/// Ana sayfadaki bir liste: kullanıcının verdiği ad, kaynak ve son
/// açılıştan kalan özet bilgiler.
class SavedSource {
  const SavedSource({
    required this.id,
    required this.name,
    required this.source,
    this.channelCount,
    this.expiresAt,
    this.lastOpenedAt,
  });

  final String id;
  final String name;
  final PlaylistSource source;

  /// Son başarılı yüklemedeki kanal sayısı.
  final int? channelCount;

  /// Xtream hesabının bitiş tarihi (son yüklemedeki).
  final DateTime? expiresAt;
  final DateTime? lastOpenedAt;

  SavedSource copyWith({
    String? name,
    PlaylistSource? source,
    int? channelCount,
    DateTime? expiresAt,
    DateTime? lastOpenedAt,
  }) =>
      SavedSource(
        id: id,
        name: name ?? this.name,
        source: source ?? this.source,
        channelCount: channelCount ?? this.channelCount,
        expiresAt: expiresAt ?? this.expiresAt,
        lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'source': source.toJson(),
        'channelCount': channelCount,
        'expiresAt': expiresAt?.toIso8601String(),
        'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      };

  static SavedSource fromJson(Map<String, dynamic> json) => SavedSource(
        id: json['id'] as String,
        name: json['name'] as String,
        source: PlaylistSource.fromJson(json['source'] as Map<String, dynamic>),
        channelCount: json['channelCount'] as int?,
        expiresAt: DateTime.tryParse('${json['expiresAt']}'),
        lastOpenedAt: DateTime.tryParse('${json['lastOpenedAt']}'),
      );

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Kullanıcı ad vermezse: sunucu adı ya da dosya adı.
  static String defaultName(PlaylistSource source) {
    final location = switch (source) {
      XtreamSource(:final server) => server,
      M3uSource(:final location) => location,
    };
    final uri = Uri.tryParse(location);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) return uri.host;
    final file = location.split(RegExp(r'[\\/]')).last;
    final dot = file.lastIndexOf('.');
    final name = dot > 0 ? file.substring(0, dot) : file;
    return name.isEmpty ? 'Liste' : name;
  }
}

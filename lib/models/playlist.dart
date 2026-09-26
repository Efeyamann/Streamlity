/// Bir oynatma listesindeki tek kanal.
class Channel {
  Channel({
    required this.name,
    required this.url,
    this.group,
    this.logo,
    this.tvgId,
    this.id,
    this.archiveDays = 0,
  });

  final String name;
  final String url;
  final String? group;
  final String? logo;

  /// EPG eşleştirmesi için kullanılan kimlik (`tvg-id`).
  final String? tvgId;

  /// Kaynağın verdiği kalıcı kimlik (Xtream `stream_id`); M3U'da null.
  final String? id;

  /// Sağlayıcının geçmiş yayını sakladığı gün sayısı (Xtream `tv_archive`);
  /// 0 ise geçmiş yayın yok.
  final int archiveDays;

  /// Favoriler gibi cihazda saklanan veriler için anahtar. URL'de kimlik
  /// bilgisi olabildiği ve bazı sağlayıcılar URL'yi değiştirdiği için
  /// kullanılmaz.
  String get key => id ?? '${group ?? ''}\u0000$name';

  /// Sağlayıcıların listeye koyduğu `#### NEWS ####` gibi başlık satırları
  /// için başlık metni; gerçek kanallarda null.
  late final String? separatorLabel = _separatorLabel(name);

  bool get isSeparator => separatorLabel != null;
}

final _separator = RegExp(r'^\s*([#=*~\-━═▬★●◆])\1+\s*(.*?)\s*\1{2,}\s*$');

String? _separatorLabel(String name) {
  final m = _separator.firstMatch(name);
  if (m == null) return null;
  // `####` gibi yalnız işaretten oluşan satırlar da ayraçtır.
  return m.group(2)!.replaceAll(RegExp(r'^[#=*~\-━═▬★●◆\s]+'), '');
}

class Playlist {
  Playlist({
    required this.channels,
    this.epgUrl,
    this.expiresAt,
    this.serverOffset,
  });

  static const ungrouped = 'Grupsuz';

  /// Ayraç satırları dahil, sağlayıcının sırasıyla.
  final List<Channel> channels;

  /// M3U başlığındaki `url-tvg` / `x-tvg-url` ya da Xtream `xmltv.php` adresi.
  final String? epgUrl;

  /// Xtream hesabının bitiş tarihi; sınırsız hesaplarda ve M3U'da null.
  final DateTime? expiresAt;

  /// Xtream sunucusunun saatinin UTC'den farkı; geçmiş yayın adresleri
  /// sunucu saatiyle yazılır. Bilinmiyorsa null.
  final Duration? serverOffset;

  /// Ayraçlar hariç kanal sayısı.
  late final int channelCount = channels.where((c) => !c.isSeparator).length;

  /// Gruplar, listede ilk göründükleri sırayla.
  late final List<String> groups = {
    for (final c in channels) c.group ?? ungrouped,
  }.toList();

  /// Grup başına kanal sayısı (ayraçlar hariç).
  late final Map<String, int> groupCounts = () {
    final counts = <String, int>{};
    for (final c in channels) {
      if (c.isSeparator) continue;
      final g = c.group ?? ungrouped;
      counts[g] = (counts[g] ?? 0) + 1;
    }
    return counts;
  }();
}

/// Arama için karşılaştırma anahtarı. Türkçe İ/I/ı ve i aynı sayılır;
/// sağlayıcılar "FİLMLER" de "FILMLER" de yazabiliyor.
String searchKey(String s) => s.toLowerCase().replaceAll(_iVariants, 'i');

final _iVariants = RegExp('i̇|ı');

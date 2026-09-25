/// Yayın akışındaki tek program.
class Programme {
  const Programme({
    required this.start,
    required this.stop,
    required this.title,
    this.description,
  });

  /// UTC.
  final DateTime start;

  /// UTC.
  final DateTime stop;
  final String title;
  final String? description;

  /// [now] anında programın ne kadarının geçtiği (0–1).
  double progress(DateTime now) {
    final total = stop.difference(start).inSeconds;
    if (total <= 0) return 0;
    return (now.difference(start).inSeconds / total).clamp(0.0, 1.0);
  }
}

/// Kanal kimliğine (`tvg-id`) göre gruplanmış yayın akışı.
class Epg {
  /// [byChannel] anahtarları küçük harfe çevrilmiş kanal kimlikleri, listeler
  /// başlangıç zamanına göre sıralı olmalı.
  Epg(this._byChannel);

  static final empty = Epg(const {});

  /// Birden fazla kaynağı birleştirir; aynı kanal için ilk kaynak geçerli.
  factory Epg.combine(Iterable<Epg> parts) {
    final merged = <String, List<Programme>>{};
    for (final part in parts) {
      for (final MapEntry(:key, :value) in part._byChannel.entries) {
        merged.putIfAbsent(key, () => value);
      }
    }
    return Epg(merged);
  }

  final Map<String, List<Programme>> _byChannel;

  int get channelCount => _byChannel.length;

  /// Sağlayıcılar kimliklerin büyük/küçük harfinde tutarsız olabildiği için
  /// eşleştirme harf duyarsız.
  List<Programme> programmesFor(String? tvgId) =>
      tvgId == null ? const [] : _byChannel[tvgId.toLowerCase()] ?? const [];

  /// [now] anında yayında olan program.
  Programme? current(String? tvgId, DateTime now) {
    final list = programmesFor(tvgId);
    final i = _lastStartedAt(list, now);
    if (i < 0) return null;
    final p = list[i];
    return p.stop.isAfter(now) ? p : null;
  }

  /// [now] anından sonra başlayan ilk program.
  Programme? next(String? tvgId, DateTime now) {
    final list = programmesFor(tvgId);
    final i = _lastStartedAt(list, now) + 1;
    return i < list.length ? list[i] : null;
  }

  /// Başlangıcı [now] ya da öncesi olan son programın indeksi; yoksa -1.
  static int _lastStartedAt(List<Programme> list, DateTime now) {
    var lo = 0, hi = list.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (list[mid].start.isAfter(now)) {
        hi = mid;
      } else {
        lo = mid + 1;
      }
    }
    return lo - 1;
  }
}

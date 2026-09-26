/// Xtream film ve dizi kataloğu.
library;

enum VodKind { movie, series }

class VodCategory {
  const VodCategory({required this.id, required this.name});

  final String id;
  final String name;
}

/// Katalogdaki tek film ya da dizi (liste görünümü için özet).
class VodItem {
  const VodItem({
    required this.kind,
    required this.id,
    required this.name,
    this.categoryId,
    this.poster,
    this.rating,
    this.year,
    this.extension,
    this.plot,
  });

  final VodKind kind;

  /// Film için `stream_id`, dizi için `series_id`.
  final String id;
  final String name;
  final String? categoryId;
  final String? poster;

  /// 0–10.
  final double? rating;
  final int? year;

  /// Yalnız film: dosya uzantısı (`mkv`, `mp4`…).
  final String? extension;
  final String? plot;

  /// İzleme konumu gibi cihazda saklanan veriler için anahtar.
  String get key => '${kind == VodKind.movie ? 'm' : 's'}:$id';
}

/// Film ya da dizinin ayrıntı sayfasındaki bilgiler.
class VodDetails {
  const VodDetails({
    this.plot,
    this.genre,
    this.cast,
    this.director,
    this.releaseDate,
    this.duration,
    this.backdrop,
  });

  final String? plot;
  final String? genre;
  final String? cast;
  final String? director;
  final String? releaseDate;
  final Duration? duration;
  final String? backdrop;
}

class Episode {
  const Episode({
    required this.id,
    required this.season,
    required this.number,
    required this.title,
    required this.extension,
    this.plot,
    this.duration,
    this.image,
  });

  final String id;
  final int season;
  final int number;
  final String title;
  final String extension;
  final String? plot;
  final Duration? duration;
  final String? image;

  String get key => 'e:$id';
}

class SeriesDetails {
  const SeriesDetails({required this.info, required this.seasons});

  final VodDetails info;

  /// Sezon numarası -> bölümler (bölüm sırasıyla). Sezonlar artan sırada.
  final Map<int, List<Episode>> seasons;
}

/// Bir kategorinin ya da tüm kataloğun öğeleri.
class VodCatalog {
  VodCatalog({required this.categories, required this.items});

  final List<VodCategory> categories;
  final List<VodItem> items;
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/playlist_source.dart';
import 'favorites_store.dart';

/// Film ve bölümlerde kalınan yer.
class WatchProgress {
  const WatchProgress({required this.position, required this.duration});

  final Duration position;
  final Duration duration;

  /// Baştaki ilk dakika ve sondaki jenerik "izlenmemiş/bitmiş" sayılır.
  bool get resumable =>
      position > const Duration(minutes: 1) &&
      (duration <= Duration.zero ||
          position < duration - const Duration(minutes: 2));

  bool get finished =>
      duration > Duration.zero &&
      position >= duration - const Duration(minutes: 2);

  double get fraction => duration <= Duration.zero
      ? 0
      : (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
}

/// Ana sayfadaki "İzlemeye devam et" rafının kataloğu yüklemeden çizip
/// oynatabilmesi için kayıtla birlikte saklanan bilgiler. Kimlik bilgisi
/// içermez; adres oynatırken kaynaktan kurulur.
@immutable
class WatchMeta {
  const WatchMeta({
    required this.title,
    required this.streamId,
    required this.extension,
    this.subtitle,
    this.poster,
    this.seriesId,
    this.season,
    this.episode,
    this.episodeTitle,
    this.categoryId,
  });

  /// Film adı ya da bölümse dizi adı.
  final String title;

  /// Eski sürümlerin yazdığı hazır alt başlık ("S1 B2 · Bölüm adı");
  /// yenileri [season], [episode] ve [episodeTitle]'dan arayüz dilinde
  /// kurulur.
  final String? subtitle;
  final String? poster;

  /// Film `stream_id`'si ya da bölüm kimliği.
  final String streamId;
  final String extension;

  /// Bölümse dizinin kimliği; film ise null.
  final String? seriesId;

  final int? season;
  final int? episode;
  final String? episodeTitle;

  /// Filmin ya da dizinin kategorisi; kilitli kategorilerin kayıtları
  /// devam rafında çıkmasın diye. Eski kayıtlarda yok.
  final String? categoryId;

  bool get isEpisode => seriesId != null;

  Map<String, Object> toJson() => {
        'title': title,
        'id': streamId,
        'ext': extension,
        'subtitle': ?subtitle,
        'poster': ?poster,
        'series': ?seriesId,
        'season': ?season,
        'episode': ?episode,
        'episodeTitle': ?episodeTitle,
        'category': ?categoryId,
      };

  static WatchMeta? fromJson(Object? json) {
    if (json is! Map) return null;
    final title = json['title'], id = json['id'], ext = json['ext'];
    if (title is! String || id is! String || ext is! String) return null;
    String? text(Object? v) => v is String ? v : null;
    int? number(Object? v) => v is num ? v.toInt() : null;
    return WatchMeta(
      title: title,
      streamId: id,
      extension: ext,
      subtitle: text(json['subtitle']),
      poster: text(json['poster']),
      seriesId: text(json['series']),
      season: number(json['season']),
      episode: number(json['episode']),
      episodeTitle: text(json['episodeTitle']),
      categoryId: text(json['category']),
    );
  }
}

/// Bir öğenin kaydı: konum, son izlenme zamanı ve (varsa) bilgileri.
class WatchEntry {
  const WatchEntry({
    required this.key,
    required this.progress,
    required this.updatedAt,
    this.meta,
  });

  final String key;
  final WatchProgress progress;
  final DateTime updatedAt;
  final WatchMeta? meta;
}

/// "İzlemeye devam et" rafı: bilgisi olan, yarım kalmış kayıtlar; dizide
/// yalnız en son izlenen bölüm. [entries] son izlenen başta sıralı olmalı.
List<WatchEntry> continueWatchingOf(Iterable<WatchEntry> entries,
    {int limit = 20}) {
  final seenSeries = <String>{};
  return [
    for (final e in entries)
      if (e.meta case final meta?
          when e.progress.resumable &&
              (meta.seriesId == null || seenSeries.add(meta.seriesId!)))
        e,
  ].take(limit).toList();
}

/// Kaynak başına öğe anahtarı ([VodItem.key], [Episode.key]) -> konum.
/// Kimlik bilgisi yazılmaz; kaynak yalnız özetiyle ([FavoritesStore.sourceKey]).
///
/// Kayıt biçimi `{"p": saniye, "d": saniye, "t": unix, "m": {...}}`; eski
/// sürümlerin yazdığı `[konum, süre, zaman]` dizileri de okunur.
class WatchProgressStore {
  WatchProgressStore({Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;
  Map<String, Map<String, Object?>>? _cache;
  Future<void> _pending = Future.value();

  Future<File> _file() async => File(
      '${(await _directory()).path}${Platform.pathSeparator}progress.json');

  Future<Map<String, Map<String, Object?>>> _readAll() async {
    if (_cache != null) return _cache!;
    try {
      final json = jsonDecode(await (await _file()).readAsString())
          as Map<String, dynamic>;
      _cache = {
        for (final MapEntry(:key, :value) in json.entries)
          key: {...(value as Map<String, dynamic>)},
      };
    } on Exception {
      _cache = {};
    } on TypeError {
      _cache = {};
    }
    return _cache!;
  }

  static WatchEntry? _decode(String key, Object? value) {
    int? at(Object? v) => v is num ? v.toInt() : null;
    int? p, d, t;
    WatchMeta? meta;
    if (value is List && value.length >= 2) {
      p = at(value[0]);
      d = at(value[1]);
      t = value.length > 2 ? at(value[2]) : null;
    } else if (value is Map) {
      p = at(value['p']);
      d = at(value['d']);
      t = at(value['t']);
      meta = WatchMeta.fromJson(value['m']);
    }
    if (p == null || d == null) return null;
    return WatchEntry(
      key: key,
      progress: WatchProgress(
          position: Duration(seconds: p), duration: Duration(seconds: d)),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((t ?? 0) * 1000),
      meta: meta,
    );
  }

  Future<List<WatchEntry>> _entries(PlaylistSource source) async {
    final raw = (await _readAll())[FavoritesStore.sourceKey(source)] ?? {};
    return [
      for (final MapEntry(:key, :value) in raw.entries) ?_decode(key, value),
    ];
  }

  Future<Map<String, WatchProgress>> read(PlaylistSource source) async => {
        for (final e in await _entries(source)) e.key: e.progress,
      };

  /// Son izlenen başta.
  Future<List<WatchEntry>> entries(PlaylistSource source) async =>
      (await _entries(source))
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// [meta] verilmezse öğenin önceki bilgileri korunur.
  Future<void> write(
      PlaylistSource source, String itemKey, WatchProgress progress,
      {WatchMeta? meta}) {
    return _pending = _pending.then((_) async {
      final all = await _readAll();
      final items = all[FavoritesStore.sourceKey(source)] ??= {};
      final previous = _decode(itemKey, items[itemKey])?.meta;
      final m = meta ?? previous;
      items[itemKey] = {
        'p': progress.position.inSeconds,
        'd': progress.duration.inSeconds,
        't': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'm': ?m?.toJson(),
      };
      final file = await _file();
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(all), flush: true);
      await temp.rename(file.path);
    }).catchError((Object e) => debugPrint('İzleme konumu kaydedilemedi: $e'));
  }
}

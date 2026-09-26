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

/// Kaynak başına öğe anahtarı ([VodItem.key], [Episode.key]) -> konum.
/// Kimlik bilgisi yazılmaz; kaynak yalnız özetiyle ([FavoritesStore.sourceKey]).
class WatchProgressStore {
  WatchProgressStore({Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;
  Map<String, Map<String, List<int>>>? _cache;
  Future<void> _pending = Future.value();

  Future<File> _file() async => File(
      '${(await _directory()).path}${Platform.pathSeparator}progress.json');

  Future<Map<String, Map<String, List<int>>>> _readAll() async {
    if (_cache != null) return _cache!;
    try {
      final json = jsonDecode(await (await _file()).readAsString())
          as Map<String, dynamic>;
      _cache = {
        for (final MapEntry(:key, :value) in json.entries)
          key: {
            for (final e in (value as Map<String, dynamic>).entries)
              e.key: (e.value as List).cast<int>(),
          },
      };
    } on Exception {
      _cache = {};
    } on TypeError {
      _cache = {};
    }
    return _cache!;
  }

  Future<Map<String, WatchProgress>> read(PlaylistSource source) async {
    final entries = (await _readAll())[FavoritesStore.sourceKey(source)] ?? {};
    return {
      for (final MapEntry(:key, :value) in entries.entries)
        if (value.length >= 2)
          key: WatchProgress(
            position: Duration(seconds: value[0]),
            duration: Duration(seconds: value[1]),
          ),
    };
  }

  Future<void> write(
      PlaylistSource source, String itemKey, WatchProgress progress) {
    return _pending = _pending.then((_) async {
      final all = await _readAll();
      (all[FavoritesStore.sourceKey(source)] ??= {})[itemKey] = [
        progress.position.inSeconds,
        progress.duration.inSeconds,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ];
      final file = await _file();
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(all), flush: true);
      await temp.rename(file.path);
    }).catchError((Object e) => debugPrint('İzleme konumu kaydedilemedi: $e'));
  }
}

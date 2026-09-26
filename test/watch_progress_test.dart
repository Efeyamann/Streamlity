import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/playlist_source.dart';
import 'package:streamlity/services/favorites_store.dart';
import 'package:streamlity/services/watch_progress_store.dart';

void main() {
  late Directory dir;
  final xtream =
      XtreamSource(server: 'http://s.tv', username: 'u', password: 'gizli');

  setUp(() => dir = Directory.systemTemp.createTempSync('progress_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  File file() => File('${dir.path}${Platform.pathSeparator}progress.json');

  test('eski dizi biçimindeki kayıtlar okunur', () async {
    final key = FavoritesStore.sourceKey(xtream);
    file().writeAsStringSync('{"$key": {"m:1": [600, 5400, 1700000000]}}');
    final store = WatchProgressStore(directory: () async => dir);
    final progress = (await store.read(xtream))['m:1']!;
    expect(progress.position, const Duration(minutes: 10));
    expect(progress.duration, const Duration(minutes: 90));
    final entry = (await store.entries(xtream)).single;
    expect(entry.meta, isNull);
    expect(entry.updatedAt.millisecondsSinceEpoch, 1700000000 * 1000);
  });

  test('bilgiler saklanır ve bilgisiz yazımda korunur', () async {
    final store = WatchProgressStore(directory: () async => dir);
    const meta = WatchMeta(
      title: 'Dizi',
      subtitle: 'S1 B2 · Bölüm',
      poster: 'http://p/x.jpg',
      streamId: '42',
      extension: 'mkv',
      seriesId: '7',
    );
    await store.write(
        xtream,
        'e:42',
        const WatchProgress(
            position: Duration(minutes: 5), duration: Duration(minutes: 50)),
        meta: meta);
    await store.write(
        xtream,
        'e:42',
        const WatchProgress(
            position: Duration(minutes: 6), duration: Duration(minutes: 50)));

    final fresh = WatchProgressStore(directory: () async => dir);
    final entry = (await fresh.entries(xtream)).single;
    expect(entry.progress.position, const Duration(minutes: 6));
    expect(entry.meta?.title, 'Dizi');
    expect(entry.meta?.subtitle, 'S1 B2 · Bölüm');
    expect(entry.meta?.isEpisode, isTrue);
    expect(entry.meta?.extension, 'mkv');
    expect(file().readAsStringSync(), isNot(contains('gizli')));
  });

  test('son izlenen başta sıralanır', () async {
    final key = FavoritesStore.sourceKey(xtream);
    file().writeAsStringSync('{"$key": {'
        '"m:1": {"p": 100, "d": 900, "t": 10},'
        '"m:2": {"p": 100, "d": 900, "t": 30},'
        '"m:3": [100, 900, 20]}}');
    final store = WatchProgressStore(directory: () async => dir);
    expect([for (final e in await store.entries(xtream)) e.key],
        ['m:2', 'm:3', 'm:1']);
  });

  test('devam rafı yarım kalanları ve dizi başına bir bölümü alır', () {
    WatchEntry entry(String key, int minutes, {String? series, bool meta = true}) =>
        WatchEntry(
          key: key,
          progress: WatchProgress(
              position: Duration(minutes: minutes),
              duration: const Duration(minutes: 50)),
          updatedAt: DateTime(2026),
          meta: meta
              ? WatchMeta(
                  title: key, streamId: key, extension: 'mp4', seriesId: series)
              : null,
        );
    final shelf = continueWatchingOf([
      entry('e:2', 10, series: 's1'), // en son izlenen bölüm
      entry('e:1', 20, series: 's1'), // aynı dizinin eski bölümü
      entry('m:1', 30),
      entry('m:2', 0), // başlanmamış
      entry('m:3', 49), // bitmiş
      entry('m:4', 10, meta: false), // eski kayıt, bilgisi yok
    ]);
    expect([for (final e in shelf) e.key], ['e:2', 'm:1']);
  });
}

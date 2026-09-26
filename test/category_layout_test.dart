import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/category_layout.dart';
import 'package:streamlity/models/playlist_source.dart';
import 'package:streamlity/services/category_layout_store.dart';

void main() {
  const provider = ['A', 'B', 'C', 'D'];
  String id(String s) => s;

  test('düzen yoksa sağlayıcının sırası', () {
    expect(CategoryLayout.empty.visible(provider, id), provider);
  });

  test('taşınanlar başa, kalanlar sağlayıcı sırasıyla', () {
    const layout = CategoryLayout(order: ['C', 'A']);
    expect(layout.arrange(provider, id), ['C', 'A', 'B', 'D']);
  });

  test('artık olmayan ve tekrarlanan anahtarlar yok sayılır', () {
    const layout = CategoryLayout(order: ['X', 'D', 'D', 'B']);
    expect(layout.arrange(provider, id), ['D', 'B', 'A', 'C']);
  });

  test('gizliler yalnız görünen listeden çıkar', () {
    const layout = CategoryLayout(order: ['C'], hidden: {'A', 'C'});
    expect(layout.visible(provider, id), ['B', 'D']);
    expect(layout.arrange(provider, id), ['C', 'A', 'B', 'D']);
  });

  test('kilitliler yalnız kilitler kapalıyken toplu görünümden çıkar', () {
    const layout = CategoryLayout(hidden: {'A'}, locked: {'B'});
    expect(layout.excluded(locksActive: true), {'A', 'B'});
    expect(layout.excluded(locksActive: false), {'A'});
    // Kilitli kategori listede görünür (kilit simgesiyle).
    expect(layout.visible(provider, id), ['B', 'C', 'D']);
    expect(layout.withoutLocks().locked, isEmpty);
    expect(layout.withoutLocks().hidden, {'A'});
  });

  group('depo', () {
    late Directory dir;
    final source =
        XtreamSource(server: 'http://s.tv', username: 'u', password: 'p');

    setUp(() => dir = Directory.systemTemp.createTempSync('layout_test'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('türler birbirine karışmaz', () async {
      final store = CategoryLayoutStore(directory: () async => dir);
      await store.write(source, CategoryKind.live,
          const CategoryLayout(order: ['TR| SPOR'], hidden: {'UK| NEWS'}));
      await store.write(source, CategoryKind.movies,
          const CategoryLayout(order: ['12'], hidden: {'7'}, locked: {'9'}));

      final fresh = CategoryLayoutStore(directory: () async => dir);
      final live = await fresh.read(source, CategoryKind.live);
      final movies = await fresh.read(source, CategoryKind.movies);
      final series = await fresh.read(source, CategoryKind.series);
      expect(live.order, ['TR| SPOR']);
      expect(live.hidden, {'UK| NEWS'});
      expect(movies.order, ['12']);
      expect(movies.hidden, {'7'});
      expect(movies.locked, {'9'});
      expect(live.locked, isEmpty);
      expect(series.isEmpty, isTrue);

      // Bir türü yeniden yazmak diğerini silmez.
      await fresh.write(source, CategoryKind.live, CategoryLayout.empty);
      expect((await fresh.read(source, CategoryKind.live)).isEmpty, isTrue);
      expect((await fresh.read(source, CategoryKind.movies)).order, ['12']);
      expect((await fresh.read(source, CategoryKind.movies)).locked, {'9'});
    });
  });
}

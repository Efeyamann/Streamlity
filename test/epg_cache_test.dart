import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/epg.dart';
import 'package:streamlity/services/epg_cache.dart';
import 'package:streamlity/services/epg_loader.dart';

const _url = 'http://s.tv/xmltv.php?username=u&password=gizli';

String _xml(String title) =>
    '<tv><programme start="20260925180000 +0000" stop="20260925190000 +0000" '
    'channel="A.tv"><title>$title</title></programme></tv>';

List<String> _titles(List<Epg> results) => [
      for (final epg in results) epg.programmesFor('A.tv').single.title,
    ];

void main() {
  late Directory dir;
  late EpgCache cache;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('streamlity_epg');
    cache = EpgCache(dir.path);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Stream<Epg> load(Future<List<int>> Function(String) fetch) => loadEpgWith(
        urls: const [_url],
        ids: const {'a.tv'},
        cache: cache,
        fetch: fetch,
      );

  Future<List<int>> fails(String _) async =>
      throw const SocketException('bağlantı yok');

  test('kayıt yoksa indirir ve kaydeder', () async {
    final results = await load((_) async => utf8.encode(_xml('Yeni'))).toList();
    expect(_titles(results), ['Yeni']);
    final saved = await cache.read(_url);
    expect(utf8.decode(saved!.xml), _xml('Yeni'));
  });

  test('dosya adında kimlik bilgisi yok, içerik sıkıştırılmış', () async {
    await cache.write(_url, utf8.encode(_xml('X')));
    final files = dir.listSync().whereType<File>().toList();
    expect(files, hasLength(1));
    expect(files.single.path, isNot(contains('gizli')));
    expect(isGzip(files.single.readAsBytesSync()), isTrue);
  });

  test('taze kayıt varsa indirmez', () async {
    await cache.write(_url, utf8.encode(_xml('Kayıtlı')));
    final results = await load(fails).toList();
    expect(_titles(results), ['Kayıtlı']);
  });

  test('eski kayıt önce gösterilir, sonra güncellenir', () async {
    await cache.write(_url, utf8.encode(_xml('Eski')));
    _age(dir, const Duration(hours: 13));
    final results = await load((_) async => utf8.encode(_xml('Yeni'))).toList();
    expect(_titles(results), ['Eski', 'Yeni']);
    expect((await cache.read(_url))!.age, lessThan(const Duration(minutes: 1)));
  });

  test('indirme başarısızsa eski kayıtla devam eder', () async {
    await cache.write(_url, utf8.encode(_xml('Eski')));
    _age(dir, const Duration(hours: 13));
    final results = await load(fails).toList();
    expect(_titles(results), ['Eski']);
  });

  test('kayıt da indirme de yoksa hata verir', () {
    expect(load(fails).toList(), throwsException);
  });

  test('gzip gelen akışı açar', () async {
    final results =
        await load((_) async => gzip.encode(utf8.encode(_xml('Gz')))).toList();
    expect(_titles(results), ['Gz']);
    expect(utf8.decode((await cache.read(_url))!.xml), _xml('Gz'));
  });

  test('eski dosyaları temizler', () async {
    await cache.write(_url, utf8.encode(_xml('X')));
    await cache.write('http://baska.tv/epg', utf8.encode(_xml('Y')));
    final old = dir.listSync().whereType<File>().first;
    old.setLastModifiedSync(DateTime.now().subtract(const Duration(days: 8)));
    await cache.prune(const Duration(days: 7));
    expect(dir.listSync().whereType<File>(), hasLength(1));
    expect(old.existsSync(), isFalse);
  });
}

void _age(Directory dir, Duration age) {
  for (final f in dir.listSync().whereType<File>()) {
    f.setLastModifiedSync(DateTime.now().subtract(age));
  }
}

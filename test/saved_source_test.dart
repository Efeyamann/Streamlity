import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/playlist_source.dart';
import 'package:streamlity/models/saved_source.dart';
import 'package:streamlity/screens/sources_screen.dart' show formatCount;
import 'package:streamlity/services/source_store.dart';

void main() {
  final xtream =
      XtreamSource(server: 'http://pro.tv:8080', username: 'u', password: 'p');

  test('JSON üzerinden özet bilgileriyle geri yüklenir', () {
    final saved = SavedSource(
      id: '1',
      name: 'Ev',
      source: xtream,
      channelCount: 56423,
      expiresAt: DateTime.utc(2026, 10, 20),
      lastOpenedAt: DateTime.utc(2026, 9, 25, 18),
    );
    final restored = decodeSources(jsonEncode([saved.toJson()])).single;
    expect(restored.id, '1');
    expect(restored.name, 'Ev');
    expect((restored.source as XtreamSource).password, 'p');
    expect(restored.channelCount, 56423);
    expect(restored.expiresAt, DateTime.utc(2026, 10, 20));
    expect(restored.lastOpenedAt, DateTime.utc(2026, 9, 25, 18));
  });

  test('bozuk kayıt diğerlerini düşürmez', () {
    final good = SavedSource(id: '1', name: 'A', source: xtream);
    final raw = jsonEncode([
      good.toJson(),
      {'id': '2', 'name': 'B', 'source': {'type': 'bilinmeyen'}},
      'çöp',
    ]);
    expect(decodeSources(raw).map((s) => s.id), ['1']);
  });

  test('eski tek kaynak listeye taşınır', () {
    final migrated = migrateLegacySource(jsonEncode(xtream.toJson()));
    expect(migrated, hasLength(1));
    expect(migrated.single.name, 'pro.tv');
    expect((migrated.single.source as XtreamSource).username, 'u');
    expect(migrateLegacySource(null), isEmpty);
    expect(migrateLegacySource('{bozuk'), isEmpty);
  });

  test('varsayılan ad sunucudan ya da dosya adından gelir', () {
    expect(SavedSource.defaultName(xtream), 'pro.tv');
    expect(SavedSource.defaultName(const M3uSource('https://liste.tv/a.m3u')),
        'liste.tv');
    expect(SavedSource.defaultName(const M3uSource(r'C:\Listeler\spor.m3u')),
        'spor');
    expect(SavedSource.defaultName(const M3uSource('/home/efe/tv.m3u8')), 'tv');
  });

  test('kanal sayısı binlik ayraçla yazılır', () {
    expect(formatCount(7), '7');
    expect(formatCount(1000), '1.000');
    expect(formatCount(56423), '56.423');
    expect(formatCount(1234567), '1.234.567');
  });
}

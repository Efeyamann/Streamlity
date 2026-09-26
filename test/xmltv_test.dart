import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/models/epg.dart';
import 'package:streamlity/services/xmltv_parser.dart';

const _sample = '''<?xml version="1.0" encoding="utf-8" ?>
<tv generator-info-name="test">
  <channel id="SkyNews.uk"><display-name>Sky News</display-name></channel>
  <programme start="20260925180000 +0200" stop="20260925190000 +0200" channel="SkyNews.uk">
    <title lang="en">Haberler &amp; Hava</title>
    <desc>G&#252;n&#xFC;n &lt;&#246;zeti&gt;</desc>
  </programme>
  <programme channel="skynews.uk" stop="20260925200000 +0200" start="20260925190000 +0200"><title><![CDATA[A & B]]></title></programme>
  <programme start="20260925200000 +0200" channel="SkyNews.uk"><title>Gece</title></programme>
  <programme start="20260925180000 +0200" stop="20260925190000 +0200" channel="skynews.uk"><title>Kopya</title></programme>
  <programme start="20260925160000" stop="20260925170000" channel="Other.tv"><title>Diğer</title></programme>
  <programme start="20260925160000" channel="NoTitle.tv"><title></title></programme>
</tv>''';

void main() {
  group('parseXmltvTime', () {
    test('saat dilimini UTC\'ye çevirir', () {
      expect(parseXmltvTime('20260925180000 +0200'),
          DateTime.utc(2026, 9, 25, 16));
      expect(parseXmltvTime('20260925180000 -0130'),
          DateTime.utc(2026, 9, 25, 19, 30));
      expect(parseXmltvTime('202609251800'), DateTime.utc(2026, 9, 25, 18));
      expect(parseXmltvTime('2026'), isNull);
      expect(parseXmltvTime(null), isNull);
    });
  });

  group('parseXmltv', () {
    final epg = parseXmltv(_sample);

    test('kimlikleri harf duyarsız birleştirir, kopyaları atar', () {
      final list = epg.programmesFor('SKYNEWS.UK');
      expect(list.map((p) => p.title), ['Haberler & Hava', 'A & B', 'Gece']);
    });

    test('öznitelik sırasından bağımsız, varlıkları çözer', () {
      final first = epg.programmesFor('SkyNews.uk').first;
      expect(first.start, DateTime.utc(2026, 9, 25, 16));
      expect(first.stop, DateTime.utc(2026, 9, 25, 17));
      expect(first.description, 'Günün <özeti>');
    });

    test('bitişi olmayan son programa bir saat verir', () {
      final last = epg.programmesFor('SkyNews.uk').last;
      expect(last.stop, DateTime.utc(2026, 9, 25, 19));
    });

    test('başlıksız programları atlar', () {
      expect(epg.programmesFor('NoTitle.tv'), isEmpty);
      expect(epg.channelCount, 2);
    });

    test('yalnız istenen kanalları tutar', () {
      final only = parseXmltv(_sample, only: {'other.tv'});
      expect(only.channelCount, 1);
      expect(only.programmesFor('Other.tv').single.title, 'Diğer');
    });
  });

  group('Epg', () {
    final epg = parseXmltv(_sample);

    test('şu anki ve sıradaki programı bulur', () {
      final now = DateTime.utc(2026, 9, 25, 17, 30);
      expect(epg.current('SkyNews.uk', now)?.title, 'A & B');
      expect(epg.next('SkyNews.uk', now)?.title, 'Gece');
      expect(epg.current('SkyNews.uk', now)!.progress(now), 0.5);
    });

    test('akış dışındaki anlarda null döner', () {
      expect(epg.current('SkyNews.uk', DateTime.utc(2026, 9, 25, 15)), isNull);
      expect(epg.next('SkyNews.uk', DateTime.utc(2026, 9, 25, 15))?.title,
          'Haberler & Hava');
      expect(epg.current('SkyNews.uk', DateTime.utc(2026, 9, 26)), isNull);
      expect(epg.current(null, DateTime.utc(2026, 9, 25, 17)), isNull);
      expect(epg.current('Yok.tv', DateTime.utc(2026, 9, 25, 17)), isNull);
    });

    test('birleştirmede ilk kaynak geçerli', () {
      final other = parseXmltv(
          '<programme start="20260925160000" channel="SkyNews.uk"><title>X</title></programme>');
      final combined = Epg.combine([other, epg]);
      expect(combined.programmesFor('SkyNews.uk').single.title, 'X');
      expect(combined.programmesFor('Other.tv'), isNotEmpty);
    });
  });

  test('yayın akışı bugünden başlayarak yerel günlere ayrılır', () {
    Programme p(DateTime start, DateTime stop) => Programme(
        start: start.toUtc(), stop: stop.toUtc(), title: '$start');
    final now = DateTime(2026, 9, 25, 14);
    final days = scheduleByDay([
      p(DateTime(2026, 9, 24, 20), DateTime(2026, 9, 24, 22)), // dün, atlanır
      p(DateTime(2026, 9, 24, 23), DateTime(2026, 9, 25, 1)), // bugüne taşar
      p(DateTime(2026, 9, 25, 13), DateTime(2026, 9, 25, 15)),
      p(DateTime(2026, 9, 26, 9), DateTime(2026, 9, 26, 10)),
    ], now);
    expect(days.keys, [DateTime(2026, 9, 25), DateTime(2026, 9, 26)]);
    expect(days[DateTime(2026, 9, 25)]!.length, 2);
    expect(days[DateTime(2026, 9, 26)]!.single.start.toLocal().hour, 9);

    final withPast = scheduleByDay([
      p(DateTime(2026, 9, 24, 20), DateTime(2026, 9, 24, 22)),
    ], now, pastDays: 1);
    expect(withPast.keys, [DateTime(2026, 9, 24)]);
  });
}

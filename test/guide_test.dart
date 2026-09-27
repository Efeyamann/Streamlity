import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:streamlity/l10n/l10n.dart';
import 'package:streamlity/models/epg.dart';
import 'package:streamlity/models/playlist.dart';
import 'package:streamlity/screens/guide_view.dart';
import 'package:streamlity/ui/theme.dart';

Programme _p(DateTime start, int minutes, [String title = 'P']) => Programme(
      start: start,
      stop: start.add(Duration(minutes: minutes)),
      title: title,
    );

void main() {
  group('guideRange', () {
    final now = DateTime(2026, 9, 27, 14, 20);

    test('bugünün gece yarısından en geç biten programa, saat başına', () {
      final range = guideRange([
        [_p(DateTime(2026, 9, 27, 10), 60)],
        [_p(DateTime(2026, 9, 28, 22, 10), 30)],
      ], now);
      expect(range.start, DateTime(2026, 9, 27));
      expect(range.end, DateTime(2026, 9, 28, 23));
    });

    test('akış kısaysa en az altı saat ileri, arşivde günler geri', () {
      final range = guideRange([
        [_p(DateTime(2026, 9, 27, 14), 30)],
      ], now, pastDays: 2);
      expect(range.start, DateTime(2026, 9, 25));
      expect(range.end, DateTime(2026, 9, 27, 21));
    });

    test('bitiş en fazla futureDays gün sonrasının sonu', () {
      final range = guideRange([
        [_p(DateTime(2026, 10, 30), 60)],
      ], now, futureDays: 2);
      expect(range.end, DateTime(2026, 9, 30));
    });
  });

  test('programmesBetween aralığa taşanları da verir', () {
    final base = DateTime.utc(2026, 9, 27, 12);
    final list = [
      for (var i = 0; i < 6; i++) _p(base.add(Duration(hours: i)), 60),
    ];
    // 13:30–15:10: 13, 14 ve 15'teki programlar.
    expect(
      programmesBetween(list, base.add(const Duration(minutes: 90)),
          base.add(const Duration(minutes: 190))),
      (1, 4),
    );
    // Tam sınırda başlayan program önceki aralığa girmez.
    expect(
      programmesBetween(list, base, base.add(const Duration(hours: 1))),
      (0, 1),
    );
    expect(programmesBetween(list, base.add(const Duration(hours: 8)),
        base.add(const Duration(hours: 9))), (6, 6));
    expect(programmesBetween(const [], base, base), (0, 0));
  });

  test('dayLabel bugün, yarın, dün ve tarih', () async {
    await initializeDateFormatting('tr');
    final l = await AppLocalizations.delegate.load(const Locale('tr'));
    final now = DateTime(2026, 9, 27, 23, 30);
    expect(l.dayLabel(DateTime(2026, 9, 27, 1), now), 'Bugün');
    expect(l.dayLabel(DateTime(2026, 9, 28), now), 'Yarın');
    expect(l.dayLabel(DateTime(2026, 9, 26, 23), now), 'Dün');
    expect(l.dayLabel(DateTime(2026, 9, 30), now), isNot('Yarın'));
  });

  testWidgets('rehber görünen programları çizer, tıklamalar doğru eylemde',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    final onAir = _p(now.subtract(const Duration(minutes: 10)), 60, 'Haberler');
    final past = _p(now.subtract(const Duration(hours: 2)), 60, 'Sabah');
    final later =
        _p(now.add(const Duration(minutes: 50)), 60, 'Akşam Filmi');
    final epg = Epg({
      'a': [past, onAir, later],
    });
    final withEpg = Channel(
        name: 'Kanal A', url: 'http://a', tvgId: 'A', id: '1', archiveDays: 3);
    final without = Channel(name: 'Kanal B', url: 'http://b', tvgId: 'b');
    Channel? watched;
    Programme? archived;

    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(),
      locale: const Locale('tr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: GuideView(
          channels: [withEpg, without],
          epg: epg,
          now: now,
          archiveDays: (c) => c.archiveDays,
          onWatch: (c) => watched = c,
          onArchive: (c, p) => archived = p,
          onSchedule: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Haberler'), findsOneWidget);
    expect(find.text('Akşam Filmi'), findsOneWidget);
    expect(find.text('Program bilgisi yok'), findsOneWidget);
    // Açılış yarım saat öncesinden; iki saat önceki program görünmez.
    expect(find.text('Sabah'), findsNothing);

    await tester.tap(find.text('Haberler'));
    expect(watched, same(withEpg));

    // Sola kaydırınca geçmiş program çıkar; arşivde olduğu için oynar.
    await tester.drag(find.byType(SingleChildScrollView), const Offset(800, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sabah'));
    expect(archived, same(past));
  });
}

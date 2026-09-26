import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/l10n/l10n.dart';
import 'package:streamlity/services/playlist_loader.dart';
import 'package:streamlity/services/watch_progress_store.dart';

/// Mesajdaki yer tutucu adları: `{name}` ya da `{count, plural, ...}`.
/// Çoğul dallarının metni (`=0{Gizli kategori yok}`) sayılmaz.
Set<String> _placeholders(String message) => {
      for (final m
          in RegExp(r'\{([A-Za-z_]\w*)\s*[,}]').allMatches(message))
        m.group(1)!,
    };

Map<String, dynamic> _arb(String code) => jsonDecode(
        File('lib/l10n/app_$code.arb').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final template = _arb('tr');
  final keys = {
    for (final k in template.keys)
      if (!k.startsWith('@')) k,
  };

  test('her dil listede ve bir çeviri dosyası var', () {
    expect(appLanguages.length, 12);
    for (final (code, _) in appLanguages) {
      expect(File('lib/l10n/app_$code.arb').existsSync(), isTrue,
          reason: code);
    }
    expect({for (final l in AppLocalizations.supportedLocales) l.languageCode},
        {for (final (code, _) in appLanguages) code});
  });

  for (final (code, _) in appLanguages) {
    test('$code: anahtarlar ve yer tutucular şablonla aynı', () {
      final arb = _arb(code);
      final own = {
        for (final k in arb.keys)
          if (!k.startsWith('@')) k,
      };
      expect(own.difference(keys), isEmpty, reason: 'fazla anahtar');
      expect(keys.difference(own), isEmpty, reason: 'eksik anahtar');
      for (final k in keys) {
        final expected = _placeholders(template[k] as String);
        final actual = _placeholders(arb[k] as String);
        expect(actual, expected, reason: '$code/$k');
        expect((arb[k] as String).trim(), isNotEmpty, reason: '$code/$k');
      }
    });
  }

  test('sistem dili desteklenmiyorsa İngilizce', () {
    final supported = AppLocalizations.supportedLocales;
    expect(resolveAppLocale([const Locale('de', 'DE')], supported),
        const Locale('de'));
    expect(resolveAppLocale([const Locale('ja')], supported),
        const Locale('en'));
    expect(
        resolveAppLocale(
            [const Locale('xx'), const Locale('fr', 'CA')], supported),
        const Locale('fr'));
    expect(resolveAppLocale(null, supported), const Locale('en'));
  });

  test('sayı, büyük harf ve süre dile göre', () {
    final tr = lookupAppLocalizations(const Locale('tr'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(tr.count(56488), '56.488');
    expect(en.count(56488), '56,488');
    expect(tr.upper('Tüm kategoriler'), 'TÜM KATEGORİLER');
    expect(en.upper('All categories'), 'ALL CATEGORIES');
    expect(tr.duration(const Duration(minutes: 101)), '1 sa 41 dk');
    expect(en.duration(const Duration(minutes: 45)), '45 min');
    expect(tr.channelCount(56488), '56.488 kanal');
    expect(en.channelCount(1), '1 channel');
    expect(tr.group('Grupsuz'), 'Grupsuz');
    expect(en.group('Grupsuz'), 'Ungrouped');
  });

  test('servis hataları arayüz dilinde', () {
    final tr = lookupAppLocalizations(const Locale('tr'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(tr.error(const PlaylistException(PlaylistError.badLogin)),
        'Kullanıcı adı veya şifre hatalı.');
    expect(en.error(const PlaylistException(PlaylistError.httpStatus, '404')),
        'The server returned 404.');
    expect(en.error(StateError('x')), 'Bad state: x');
  });

  test('bölüm alt başlığı dile göre, eski kayıtta saklanan metin', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(
        watchSubtitle(
            en,
            const WatchMeta(
                title: 'Dizi',
                streamId: '1',
                extension: 'mkv',
                seriesId: '7',
                season: 1,
                episode: 2,
                episodeTitle: 'Pilot')),
        'S1 E2 · Pilot');
    expect(
        watchSubtitle(
            en,
            const WatchMeta(
                title: 'Dizi',
                streamId: '1',
                extension: 'mkv',
                subtitle: 'S1 B2 · Pilot')),
        'S1 B2 · Pilot');
  });
}

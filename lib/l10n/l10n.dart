import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../models/playlist.dart';
import '../services/playlist_loader.dart';
import '../services/watch_progress_store.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Ayarlardaki dil listesi: (kod, dilin kendi dilindeki adı). Sıra ekrandaki
/// sıradır.
const appLanguages = <(String, String)>[
  ('tr', 'Türkçe'),
  ('en', 'English'),
  ('zh', '中文（简体）'),
  ('hi', 'हिन्दी'),
  ('es', 'Español'),
  ('ar', 'العربية'),
  ('fr', 'Français'),
  ('bn', 'বাংলা'),
  ('pt', 'Português'),
  ('ru', 'Русский'),
  ('id', 'Bahasa Indonesia'),
  ('de', 'Deutsch'),
];

/// Dil kodunun kendi adı; bilinmiyorsa kodun kendisi.
String languageName(String code) =>
    appLanguages.where((l) => l.$1 == code).firstOrNull?.$2 ?? code;

/// Sistem dilleri arasından desteklenen ilkini seçer; hiçbiri yoksa İngilizce.
Locale resolveAppLocale(List<Locale>? system, Iterable<Locale> supported) {
  final codes = {for (final l in supported) l.languageCode};
  for (final l in system ?? const <Locale>[]) {
    if (codes.contains(l.languageCode)) return Locale(l.languageCode);
  }
  return const Locale('en');
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsFormat on AppLocalizations {
  /// Dile duyarlı büyük harf: Türkçe ve Azericede "i" -> "İ".
  String upper(String s) {
    if (localeName == 'tr' || localeName == 'az') {
      s = s.replaceAll('i', 'İ');
    }
    return s.toUpperCase();
  }

  /// 56488 -> "56.488" (tr), "56,488" (en)…
  String count(int n) => NumberFormat.decimalPattern(localeName).format(n);

  String date(DateTime d) => DateFormat.yMd(localeName).format(d);

  String time(DateTime t) => DateFormat.Hm(localeName).format(t.toLocal());

  /// "Pzt 26 Eyl" gibi kısa gün ve tarih.
  String weekdayDate(DateTime d) => DateFormat.MMMEd(localeName).format(d);

  /// Yerel [day] için "Bugün", "Yarın", "Dün" ya da kısa gün ve tarih.
  String dayLabel(DateTime day, DateTime now) {
    final d = day.toLocal(), n = now.toLocal();
    // Yaz saati geçişinde 23 ya da 25 saatlik günler şaşırtmasın.
    final diff = DateTime.utc(d.year, d.month, d.day)
        .difference(DateTime.utc(n.year, n.month, n.day))
        .inDays;
    return switch (diff) {
      0 => today,
      1 => tomorrow,
      -1 => yesterday,
      _ => weekdayDate(d),
    };
  }

  String duration(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    return h > 0 ? durationHoursMinutes(h, m) : durationMinutes(m);
  }

  /// Sağlayıcının "Grupsuz" iç adını ekranda dile çevirir; anahtar olarak
  /// saklandığı için kendisi değişmez.
  String group(String name) => name == Playlist.ungrouped ? ungrouped : name;

  /// Kullanıcıya gösterilecek hata metni.
  String error(Object error) {
    if (error is! PlaylistException) return '$error';
    final detail = error.detail ?? '';
    return switch (error.error) {
      PlaylistError.httpStatus => errHttpStatus(int.tryParse(detail) ?? 0),
      PlaylistError.fetchFailed => errFetchFailed(detail),
      PlaylistError.noChannels => errNoChannels,
      PlaylistError.noLiveChannels => errNoLiveChannels,
      PlaylistError.badLogin => errBadLogin,
      PlaylistError.accountUnavailable => errAccountUnavailable(detail),
      PlaylistError.connectFailed => errConnect(detail),
      PlaylistError.invalidResponse => errInvalidResponse,
      PlaylistError.noMovies => errNoMovies,
      PlaylistError.noSeries => errNoSeries,
      PlaylistError.epgFailed => errEpg(detail),
    };
  }
}

/// Devam rafındaki kaydın alt başlığı: bölümde "S1 E2 · Bölüm adı".
String? watchSubtitle(AppLocalizations l, WatchMeta meta) {
  final season = meta.season, episode = meta.episode;
  if (season == null || episode == null) return meta.subtitle;
  final code = l.episodeCode(season, episode);
  final title = meta.episodeTitle;
  return title == null || title.isEmpty ? code : '$code · $title';
}

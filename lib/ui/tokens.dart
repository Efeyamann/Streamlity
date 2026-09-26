import 'package:flutter/material.dart';

/// Uygulamanın renk token'ları. Ekranlar ham renk kullanmaz; buradan okur:
/// `AppColors.of(context).accent`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.muted,
    required this.border,
    required this.fg,
    required this.fgMuted,
    required this.fgSubtle,
    required this.accent,
    required this.onAccent,
    required this.live,
    required this.success,
    required this.warning,
    required this.danger,
    required this.focusRing,
    required this.scrim,
  });

  /// Vurgu rengi; const bağlamlar (ör. oynatıcı denetim teması) için ayrıca.
  static const accentColor = Color(0xFFE11D48);

  /// Sinema karanlığı ve oynat kırmızısı (UI/UX Pro Max, Video Streaming/OTT).
  static const cinema = AppColors(
    bg: Color(0xFF000000),
    surface: Color(0xFF0C0C0D),
    surfaceRaised: Color(0xFF141416),
    muted: Color(0xFF1C1C1F),
    border: Color(0x14FFFFFF),
    fg: Color(0xFFF8FAFC),
    fgMuted: Color(0xFF94A3B8),
    fgSubtle: Color(0xFF64748B),
    accent: accentColor,
    onAccent: Color(0xFFFFFFFF),
    live: accentColor,
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    focusRing: Color(0xFFFFFFFF),
    scrim: Color(0xCC000000),
  );

  /// Sayfa zemini.
  final Color bg;

  /// Paneller ve kartlar.
  final Color surface;

  /// Hover, açılır menü ve diyalog gibi bir kat yukarıdaki yüzeyler.
  final Color surfaceRaised;

  /// Seçili satır, çip ve iskelet zemini.
  final Color muted;
  final Color border;
  final Color fg;

  /// İkincil metin; siyah üstünde 4.5:1'in üstünde kalır.
  final Color fgMuted;

  /// Yalnız büyük ya da süs metinler için.
  final Color fgSubtle;
  final Color accent;
  final Color onAccent;
  final Color live;
  final Color success;
  final Color warning;
  final Color danger;
  final Color focusRing;

  /// Görsel üstündeki metinler ve diyalog arkası için karartma.
  final Color scrim;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? cinema;

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceRaised,
    Color? muted,
    Color? border,
    Color? fg,
    Color? fgMuted,
    Color? fgSubtle,
    Color? accent,
    Color? onAccent,
    Color? live,
    Color? success,
    Color? warning,
    Color? danger,
    Color? focusRing,
    Color? scrim,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      fg: fg ?? this.fg,
      fgMuted: fgMuted ?? this.fgMuted,
      fgSubtle: fgSubtle ?? this.fgSubtle,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      live: live ?? this.live,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      focusRing: focusRing ?? this.focusRing,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      muted: l(muted, other.muted),
      border: l(border, other.border),
      fg: l(fg, other.fg),
      fgMuted: l(fgMuted, other.fgMuted),
      fgSubtle: l(fgSubtle, other.fgSubtle),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      live: l(live, other.live),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
      focusRing: l(focusRing, other.focusRing),
      scrim: l(scrim, other.scrim),
    );
  }
}

/// 4'ün katları; boşluklar yalnız bunlardan seçilir.
abstract final class Space {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class Radii {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;

  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
}

abstract final class IconSizes {
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
}

/// Geçiş süreleri. Sistemde animasyonlar kapalıysa sıfırlanır.
class Motion {
  const Motion._(this._scale);

  final int _scale;

  static const _off = Motion._(0);
  static const _on = Motion._(1);

  static Motion of(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? _off : _on;

  /// Hover ve basma geri bildirimi.
  Duration get fast => Duration(milliseconds: 150 * _scale);

  /// Görünüp kaybolan öğeler.
  Duration get base => Duration(milliseconds: 200 * _scale);

  /// Panel ve sayfa geçişleri.
  Duration get slow => Duration(milliseconds: 300 * _scale);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}

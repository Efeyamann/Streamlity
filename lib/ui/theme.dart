import 'package:flutter/material.dart';

import 'tokens.dart';

/// Uygulamanın tek teması: sinema karanlığı, kırmızı vurgu, Inter.
ThemeData buildTheme() {
  const c = AppColors.cinema;
  final scheme = const ColorScheme.dark().copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: const Color(0xFF4C0519),
    onPrimaryContainer: const Color(0xFFFFE4E6),
    secondary: c.fgMuted,
    onSecondary: c.bg,
    secondaryContainer: c.muted,
    onSecondaryContainer: c.fg,
    tertiary: c.success,
    error: c.danger,
    onError: c.bg,
    surface: c.bg,
    onSurface: c.fg,
    onSurfaceVariant: c.fgMuted,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surfaceRaised,
    surfaceContainerHighest: c.muted,
    surfaceTint: Colors.transparent,
    outline: const Color(0x33FFFFFF),
    outlineVariant: c.border,
    inverseSurface: c.fg,
    onInverseSurface: c.bg,
    scrim: c.scrim,
  );

  final base = ThemeData(
    colorScheme: scheme,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
  );

  final text = base.textTheme.copyWith(
    displaySmall: const TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.8),
    headlineSmall: const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.4),
    titleLarge: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: c.fgMuted),
    labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1),
  ).apply(bodyColor: c.fg, displayColor: c.fg);

  // Odakta beyaz halka; klavyeyle gezen görsün (skill: visible-focus).
  const focusSide = BorderSide(color: Colors.white, width: 2);
  WidgetStateProperty<BorderSide?> focusOutline([BorderSide? rest]) =>
      WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.focused) ? focusSide : rest);

  final buttonShape = WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: Radii.mdAll));
  const buttonPadding = WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: Space.md + 4, vertical: Space.sm));

  return base.copyWith(
    textTheme: text,
    extensions: const [AppColors.cinema],
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
      toolbarHeight: 60,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: WidgetStatePropertyAll(text.labelLarge),
        side: focusOutline(),
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return c.muted;
          if (s.contains(WidgetState.hovered)) return const Color(0xFFF43F5E);
          return c.accent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.disabled) ? c.fgSubtle : c.onAccent),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: WidgetStatePropertyAll(text.labelLarge),
        foregroundColor: WidgetStatePropertyAll(c.fg),
        side: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.focused)) return focusSide;
          return BorderSide(
              color: s.contains(WidgetState.hovered)
                  ? const Color(0x66FFFFFF)
                  : const Color(0x33FFFFFF));
        }),
        overlayColor: const WidgetStatePropertyAll(Color(0x0FFFFFFF)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: buttonShape,
        textStyle: WidgetStatePropertyAll(text.labelLarge),
        foregroundColor: WidgetStatePropertyAll(c.fg),
        side: focusOutline(),
        overlayColor: const WidgetStatePropertyAll(Color(0x14FFFFFF)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.disabled) ? c.fgSubtle : c.fg),
        overlayColor: const WidgetStatePropertyAll(Color(0x1AFFFFFF)),
        side: focusOutline(),
        minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceRaised,
      hoverColor: c.muted,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
      hintStyle: text.bodyMedium?.copyWith(color: c.fgMuted),
      prefixIconColor: c.fgMuted,
      suffixIconColor: c.fgMuted,
      border: OutlineInputBorder(
          borderRadius: Radii.mdAll, borderSide: BorderSide(color: c.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll, borderSide: BorderSide(color: c.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: const BorderSide(color: Color(0x99FFFFFF), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll, borderSide: BorderSide(color: c.danger)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: c.danger, width: 1.5)),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.accent,
      selectionColor: c.accent.withValues(alpha: 0.35),
      selectionHandleColor: c.accent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      barrierColor: c.scrim,
      shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll, side: BorderSide(color: c.border)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
          borderRadius: Radii.mdAll, side: BorderSide(color: c.border)),
      textStyle: text.bodyMedium,
      labelTextStyle: WidgetStatePropertyAll(text.bodyMedium),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surfaceRaised),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: Radii.mdAll, side: BorderSide(color: c.border))),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.fg,
        borderRadius: Radii.smAll,
      ),
      textStyle: text.labelMedium?.copyWith(color: c.bg),
      padding:
          const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.xxs),
      waitDuration: const Duration(milliseconds: 400),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.surfaceRaised,
      contentTextStyle: text.bodyMedium,
      actionTextColor: c.accent,
      behavior: SnackBarBehavior.floating,
      width: 420,
      shape: RoundedRectangleBorder(
          borderRadius: Radii.mdAll, side: BorderSide(color: c.border)),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.hovered) || s.contains(WidgetState.dragged)
              ? const Color(0x66FFFFFF)
              : const Color(0x33FFFFFF)),
      radius: const Radius.circular(8),
      thickness: const WidgetStatePropertyAll(6),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.accent,
      linearTrackColor: const Color(0x26FFFFFF),
      circularTrackColor: Colors.transparent,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
      selectedColor: c.fg,
      selectedTileColor: c.muted,
      iconColor: c.fgMuted,
      textColor: c.fg,
      subtitleTextStyle: text.bodySmall,
    ),
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: c.fg,
      unselectedLabelColor: c.fgMuted,
      indicatorColor: c.accent,
      dividerColor: c.border,
      labelStyle: text.labelLarge,
      unselectedLabelStyle: text.labelLarge,
      overlayColor: const WidgetStatePropertyAll(Color(0x0FFFFFFF)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.muted,
      selectedColor: c.accent,
      side: BorderSide(color: c.border),
      shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
      labelStyle: text.labelMedium,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? c.accent : Colors.transparent),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? c.muted : Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(c.fg),
        side: WidgetStatePropertyAll(BorderSide(color: c.border)),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
    }),
  );
}

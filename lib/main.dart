import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';

import 'l10n/l10n.dart';
import 'screens/sources_screen.dart';
import 'services/app_mute.dart';
import 'services/settings_store.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // Geliştirme kolaylığı: denemelerde yayınlar sessiz başlasın.
  appMuted.value = Platform.environment['STREAMLITY_MUTED'] == '1';
  appLanguage.value = await SettingsStore().readLanguage();
  // Arapçada sayılar Latin rakamıyla yazılıyor (NumberFormat); tarih ve
  // saatler de aynı rakamlarla yazılsın, ekranda iki rakam türü karışmasın.
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
  runApp(const StreamlityApp());
}

class StreamlityApp extends StatelessWidget {
  const StreamlityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildTheme();
    return ValueListenableBuilder(
      valueListenable: appLanguage,
      builder: (context, language, _) => MaterialApp(
        onGenerateTitle: (context) => context.l10n.appTitle,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: theme,
        darkTheme: theme,
        // null: sistem diline uy (desteklenmiyorsa İngilizce).
        locale: language == null ? null : Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeListResolutionCallback: resolveAppLocale,
        home: const SourcesScreen(),
      ),
    );
  }
}

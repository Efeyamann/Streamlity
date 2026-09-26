import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/sources_screen.dart';
import 'services/app_mute.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // Geliştirme kolaylığı: denemelerde yayınlar sessiz başlasın.
  appMuted.value = Platform.environment['STREAMLITY_MUTED'] == '1';
  runApp(const StreamlityApp());
}

class StreamlityApp extends StatelessWidget {
  const StreamlityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildTheme();
    return MaterialApp(
      title: 'Streamlity',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: theme,
      darkTheme: theme,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const SourcesScreen(),
    );
  }
}

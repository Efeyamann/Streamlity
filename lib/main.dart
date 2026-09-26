import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/sources_screen.dart';
import 'services/app_mute.dart';

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
    // Siyaha yakın, nötr gri yüzeyler; mor yalnız vurgu rengi.
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF0A0A0C),
      surfaceContainerLowest: const Color(0xFF050506),
      surfaceContainerLow: const Color(0xFF111114),
      surfaceContainer: const Color(0xFF151518),
      surfaceContainerHigh: const Color(0xFF1B1B1F),
      surfaceContainerHighest: const Color(0xFF242428),
      surfaceTint: Colors.transparent,
      outlineVariant: const Color(0xFF2A2A2F),
    );
    return MaterialApp(
      title: 'Streamlity',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(colorScheme: scheme),
      theme: ThemeData(colorScheme: scheme),
      home: const SourcesScreen(),
    );
  }
}

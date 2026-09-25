import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/sources_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const StreamlityApp());
}

class StreamlityApp extends StatelessWidget {
  const StreamlityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamlity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const SourcesScreen(),
    );
  }
}

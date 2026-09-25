import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const PlayerScreen(),
    );
  }
}

/// Geçici test ekranı: girilen akış URL'sini media_kit ile oynatır.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _player.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _play() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    _player.open(Media(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'Akış URL\'si (m3u8, ts, ...)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _play(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _play, child: const Text('Oynat')),
              ],
            ),
          ),
          Expanded(child: Video(controller: _controller)),
        ],
      ),
    );
  }
}

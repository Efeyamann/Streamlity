import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;

/// Oynatıcının ses ve altyazı parçaları için üst çubuk menüleri. Seçilecek
/// bir şey yoksa (tek ses, altyazı yok) hiçbir şey göstermez.
class TrackMenus extends StatelessWidget {
  const TrackMenus({super.key, required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Tracks>(
      stream: player.stream.tracks,
      initialData: player.state.tracks,
      builder: (context, tracks) {
        final audio = [
          for (final t in tracks.data!.audio)
            if (!_pseudo(t.id)) t,
        ];
        final subtitles = [
          for (final t in tracks.data!.subtitle)
            if (!_pseudo(t.id)) t,
        ];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (audio.length > 1)
              _TrackButton<AudioTrack>(
                tooltip: 'Ses dili',
                icon: Icons.audiotrack,
                currentId: () => _currentId(
                    player.state.track.audio.id, 'audio'),
                items: [
                  for (final t in audio)
                    (t, t.id, trackLabel(t.id, t.title, t.language)),
                ],
                onSelected: player.setAudioTrack,
              ),
            if (subtitles.isNotEmpty)
              _TrackButton<SubtitleTrack>(
                tooltip: 'Altyazı',
                icon: Icons.subtitles,
                currentId: () => _currentId(
                    player.state.track.subtitle.id, 'sub'),
                items: [
                  (SubtitleTrack.no(), 'no', 'Kapalı'),
                  for (final t in subtitles)
                    (t, t.id, trackLabel(t.id, t.title, t.language)),
                ],
                onSelected: player.setSubtitleTrack,
              ),
          ],
        );
      },
    );
  }

  /// Kullanıcı seçmediyse media_kit parçayı "auto" bildirir; o zaman
  /// mpv'nin gerçekte çaldığı parçayı sor.
  Future<String> _currentId(String selected, String kind) async {
    final platform = player.platform;
    if (selected != 'auto' || platform is! NativePlayer) return selected;
    try {
      final id = await platform.getProperty('current-tracks/$kind/id');
      return int.tryParse(id) != null ? id : 'no';
    } catch (_) {
      // Parça seçili değilse mpv özelliği hiç döndürmez.
      return 'no';
    }
  }

  /// media_kit'in "otomatik" ve "kapalı" sahte parçaları.
  static bool _pseudo(String id) => id == 'auto' || id == 'no';
}

/// Açılırken çalan parçayı öğrenip işaretleyen menü düğmesi.
class _TrackButton<T> extends StatelessWidget {
  const _TrackButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.currentId,
    required this.items,
    required this.onSelected,
  });

  final String tooltip;
  final IconData icon;
  final Future<String> Function() currentId;
  final List<(T value, String id, String label)> items;
  final ValueChanged<T> onSelected;

  Future<void> _open(BuildContext context) async {
    final button = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final current = await currentId();
    if (!context.mounted) return;
    final selected = [
      for (final (value, id, _) in items)
        if (id == current) value,
    ].firstOrNull;
    final choice = await showMenu<T>(
      context: context,
      position: position,
      // Uzun listede seçili parçaya kaydırır.
      initialValue: selected,
      items: [
        for (final (value, id, label) in items)
          CheckedPopupMenuItem(
            value: value,
            checked: id == current,
            child: Text(label),
          ),
      ],
    );
    if (choice != null) onSelected(choice);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: () => _open(context),
    );
  }
}

const _languages = {
  'tur': 'Türkçe',
  'tr': 'Türkçe',
  'eng': 'İngilizce',
  'en': 'İngilizce',
  'ger': 'Almanca',
  'deu': 'Almanca',
  'de': 'Almanca',
  'fre': 'Fransızca',
  'fra': 'Fransızca',
  'fr': 'Fransızca',
  'ara': 'Arapça',
  'ar': 'Arapça',
  'rus': 'Rusça',
  'ru': 'Rusça',
  'spa': 'İspanyolca',
  'es': 'İspanyolca',
  'ita': 'İtalyanca',
  'it': 'İtalyanca',
  'kur': 'Kürtçe',
  'aze': 'Azerice',
  'chi': 'Çince',
  'zho': 'Çince',
  'zh': 'Çince',
  'jpn': 'Japonca',
  'ja': 'Japonca',
  'kor': 'Korece',
  'ko': 'Korece',
  'por': 'Portekizce',
  'pt': 'Portekizce',
  'dut': 'Felemenkçe',
  'nld': 'Felemenkçe',
  'nl': 'Felemenkçe',
  'pol': 'Lehçe',
  'pl': 'Lehçe',
  'gre': 'Yunanca',
  'ell': 'Yunanca',
  'el': 'Yunanca',
  'bul': 'Bulgarca',
  'bg': 'Bulgarca',
  'rum': 'Rumence',
  'ron': 'Rumence',
  'ro': 'Rumence',
  'hun': 'Macarca',
  'hu': 'Macarca',
  'cze': 'Çekçe',
  'ces': 'Çekçe',
  'cs': 'Çekçe',
  'slo': 'Slovakça',
  'slk': 'Slovakça',
  'slv': 'Slovence',
  'hrv': 'Hırvatça',
  'srp': 'Sırpça',
  'bos': 'Boşnakça',
  'alb': 'Arnavutça',
  'sqi': 'Arnavutça',
  'ukr': 'Ukraynaca',
  'uk': 'Ukraynaca',
  'swe': 'İsveççe',
  'sv': 'İsveççe',
  'nor': 'Norveççe',
  'nob': 'Norveççe',
  'dan': 'Danca',
  'da': 'Danca',
  'fin': 'Fince',
  'fi': 'Fince',
  'est': 'Estonca',
  'lit': 'Litvanca',
  'lav': 'Letonca',
  'ice': 'İzlandaca',
  'isl': 'İzlandaca',
  'heb': 'İbranice',
  'he': 'İbranice',
  'per': 'Farsça',
  'fas': 'Farsça',
  'hin': 'Hintçe',
  'hi': 'Hintçe',
};

/// Menüde görünen parça adı: dil adı ve varsa sağlayıcının başlığı.
String trackLabel(String id, String? title, String? language) {
  final code = language?.trim().toLowerCase();
  final lang = code == null || code.isEmpty || code == 'und'
      ? null
      : _languages[code] ?? code.toUpperCase();
  final name = title?.trim();
  if (lang != null && name != null && name.isNotEmpty && name != lang) {
    return '$lang ($name)';
  }
  return lang ?? (name != null && name.isNotEmpty ? name : 'Parça $id');
}

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;

import '../l10n/l10n.dart';

/// Oynatıcının ses ve altyazı parçaları için üst çubuk menüleri. Seçilecek
/// bir şey yoksa (tek ses, altyazı yok) hiçbir şey göstermez.
class TrackMenus extends StatelessWidget {
  const TrackMenus({super.key, required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
                tooltip: l.audioLanguage,
                icon: Icons.audiotrack,
                currentId: () => _currentId(
                    player.state.track.audio.id, 'audio'),
                items: [
                  for (final t in audio)
                    (t, t.id, trackLabel(l, t.id, t.title, t.language)),
                ],
                onSelected: player.setAudioTrack,
              ),
            if (subtitles.isNotEmpty)
              _TrackButton<SubtitleTrack>(
                tooltip: l.subtitles,
                icon: Icons.subtitles,
                currentId: () => _currentId(
                    player.state.track.subtitle.id, 'sub'),
                items: [
                  (SubtitleTrack.no(), 'no', l.subtitlesOff),
                  for (final t in subtitles)
                    (t, t.id, trackLabel(l, t.id, t.title, t.language)),
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

/// Parça dil kodları -> dilin kendi adı. Arayüz dili ne olursa olsun
/// aynıdır; izleyen kişi kendi dilini her durumda tanır.
const _languages = {
  'tur': 'Türkçe',
  'tr': 'Türkçe',
  'eng': 'English',
  'en': 'English',
  'ger': 'Deutsch',
  'deu': 'Deutsch',
  'de': 'Deutsch',
  'fre': 'Français',
  'fra': 'Français',
  'fr': 'Français',
  'ara': 'العربية',
  'ar': 'العربية',
  'rus': 'Русский',
  'ru': 'Русский',
  'spa': 'Español',
  'es': 'Español',
  'ita': 'Italiano',
  'it': 'Italiano',
  'kur': 'Kurdî',
  'aze': 'Azərbaycanca',
  'chi': '中文',
  'zho': '中文',
  'zh': '中文',
  'jpn': '日本語',
  'ja': '日本語',
  'kor': '한국어',
  'ko': '한국어',
  'por': 'Português',
  'pt': 'Português',
  'dut': 'Nederlands',
  'nld': 'Nederlands',
  'nl': 'Nederlands',
  'pol': 'Polski',
  'pl': 'Polski',
  'gre': 'Ελληνικά',
  'ell': 'Ελληνικά',
  'el': 'Ελληνικά',
  'bul': 'Български',
  'bg': 'Български',
  'rum': 'Română',
  'ron': 'Română',
  'ro': 'Română',
  'hun': 'Magyar',
  'hu': 'Magyar',
  'cze': 'Čeština',
  'ces': 'Čeština',
  'cs': 'Čeština',
  'slo': 'Slovenčina',
  'slk': 'Slovenčina',
  'slv': 'Slovenščina',
  'hrv': 'Hrvatski',
  'srp': 'Српски',
  'bos': 'Bosanski',
  'alb': 'Shqip',
  'sqi': 'Shqip',
  'ukr': 'Українська',
  'uk': 'Українська',
  'swe': 'Svenska',
  'sv': 'Svenska',
  'nor': 'Norsk',
  'nob': 'Norsk',
  'dan': 'Dansk',
  'da': 'Dansk',
  'fin': 'Suomi',
  'fi': 'Suomi',
  'est': 'Eesti',
  'lit': 'Lietuvių',
  'lav': 'Latviešu',
  'ice': 'Íslenska',
  'isl': 'Íslenska',
  'heb': 'עברית',
  'he': 'עברית',
  'per': 'فارسی',
  'fas': 'فارسی',
  'hin': 'हिन्दी',
  'hi': 'हिन्दी',
  'ben': 'বাংলা',
  'bn': 'বাংলা',
  'ind': 'Bahasa Indonesia',
  'id': 'Bahasa Indonesia',
  'urd': 'اردو',
  'ur': 'اردو',
};

/// Menüde görünen parça adı: dilin kendi adı ve varsa sağlayıcının başlığı.
String trackLabel(
    AppLocalizations l, String id, String? title, String? language) {
  final code = language?.trim().toLowerCase();
  final lang = code == null || code.isEmpty || code == 'und'
      ? null
      : _languages[code] ?? code.toUpperCase();
  final name = title?.trim();
  if (lang != null &&
      name != null &&
      name.isNotEmpty &&
      name.toLowerCase() != lang.toLowerCase()) {
    return '$lang ($name)';
  }
  return lang ?? (name != null && name.isNotEmpty ? name : l.trackNumber(id));
}

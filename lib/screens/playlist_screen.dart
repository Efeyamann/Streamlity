import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../models/category_layout.dart';
import '../models/epg.dart';
import '../models/playlist.dart';
import '../models/playlist_source.dart';
import '../models/saved_source.dart';
import '../models/vod.dart';
import '../services/app_mute.dart';
import '../services/category_layout_store.dart';
import '../services/epg_loader.dart';
import '../services/favorites_store.dart';
import '../services/playlist_loader.dart';
import '../services/stall_watchdog.dart';
import '../services/stream_slot.dart';
import '../services/watch_progress_store.dart';
import '../l10n/l10n.dart';
import '../services/xtream_vod.dart';
import '../ui/player_controls.dart';
import '../ui/tokens.dart';
import '../ui/widgets/app_rail.dart';
import '../ui/widgets/channel_tile.dart';
import '../ui/widgets/common.dart';
import 'schedule_dialog.dart';
import 'track_menu.dart';
import 'category_editor.dart';
import 'home_view.dart';
import 'search_view.dart';
import 'vod_browser.dart';
import 'vod_player_screen.dart';
import 'settings_screen.dart';

/// Bir listenin kanalları, yayın akışı ve oynatıcılar. Aynı anda birden
/// fazla kanal izlenebilir. Geri gidilince oynatıcılar kapanır.
class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({
    super.key,
    required this.saved,
    required this.onLoaded,
  });

  final SavedSource saved;

  /// Liste yüklenince; ana sayfadaki kartın özet bilgileri için.
  final void Function(int channelCount, DateTime? expiresAt) onLoaded;

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

enum _Section { home, live, movies, series, search }

class _PlaylistScreenState extends State<PlaylistScreen> {
  _Section _section = _Section.home;

  /// Ana sayfadaki "İzlemeye devam et" rafı; son izlenen başta.
  List<WatchEntry> _continue = const [];

  /// Film ve dizi katalogları ekran açıkken bir kez yüklenir.
  final _catalogs = <VodKind, Future<VodCatalog>>{};
  final _progressStore = WatchProgressStore();
  PlaylistSource get _source => widget.saved.source;
  Playlist? _playlist;
  bool _loading = true;
  Object? _error;

  Epg? _epg;
  bool _epgLoading = false;
  Object? _epgError;

  /// Akışın en son sağlayıcıyla karşılaştırıldığı an; uzun açık kalan
  /// uygulamada yenilemek için.
  DateTime? _epgCheckedAt;

  /// Yayın akışındaki "şu an" için; periyodik olarak ilerletilir.
  DateTime _now = DateTime.now();
  late final Timer _clock;

  final _recentsStore = FavoritesStore.recents();

  /// Favori kategoriler (kanal paketleri), eklenme sırasıyla.
  final _groupsStore = FavoritesStore.groups();
  List<String> _favoriteGroups = [];

  /// Kullanıcının kategori sırası ve gizledikleri.
  final _layoutStore = CategoryLayoutStore();
  CategoryLayout _groupLayout = CategoryLayout.empty;
  final _vodLayouts = <VodKind, CategoryLayout>{};

  /// Son izlenen kanalların anahtarları; en yenisi başta.
  List<String> _recents = [];
  static const _maxRecents = 30;
  static const _recentsGroup = '\u0000son';

  /// [Channel.key] -> kanal; son izlenenleri listeye çevirmek için.
  Map<String, Channel> _byKey = const {};

  /// Çoklu izlemede aynı anda açık kalabilecek en fazla kanal.
  static const _maxSlots = 4;

  final List<StreamSlot> _slots = [];

  /// Sesi açık olan ve kanal listesinden seçimin gittiği kare.
  StreamSlot? _active;

  /// Büyütülmüş kare; null ise kareler ızgarada eşit.
  StreamSlot? _focus;

  Channel? get _current => _active?.channel;

  /// null: tüm kanallar; [_recentsGroup]: son izlenenler.
  String? _group;
  String _query = '';

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Pencere kapanırken widget'lar dispose edilmez; oynatıcıyı burada
    // kapatmazsak libmpv süreç sonlanana kadar ses çalmaya devam eder.
    _lifecycle = AppLifecycleListener(
      onExitRequested: () async {
        await _disposeSlots();
        return AppExitResponse.exit;
      },
    );
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_epg != null) setState(() => _now = DateTime.now());
      final playlist = _playlist, checked = _epgCheckedAt;
      if (playlist != null &&
          !_epgLoading &&
          checked != null &&
          DateTime.now().difference(checked) > epgMaxAge) {
        _loadEpg(playlist);
      }
    });
    HardwareKeyboard.instance.addHandler(_onKey);
    appMuted.addListener(_applyMute);
    _load();
    _loadContinue();
    _loadVodLayouts();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    appMuted.removeListener(_applyMute);
    _lifecycle.dispose();
    _clock.cancel();
    _disposeSlots();
    super.dispose();
  }

  Future<void> _disposeSlots() async {
    final slots = [..._slots];
    _slots.clear();
    _active = _focus = null;
    await Future.wait(slots.map((s) => s.dispose()));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final playlist = await loadSource(_source);
      final recents = await _recentsStore.readList(_source);
      final favoriteGroups = await _groupsStore.readList(_source);
      final layout = await _layoutStore.read(_source, CategoryKind.live);
      if (!mounted) return;
      setState(() {
        _playlist = playlist;
        _byKey = {
          for (final c in playlist.channels)
            if (!c.isSeparator) c.key: c,
        };
        _recents = recents;
        _favoriteGroups = favoriteGroups;
        _groupLayout = layout;
        _group = null;
        _query = '';
      });
      widget.onLoaded(playlist.channelCount, playlist.expiresAt);
      _loadEpg(playlist);
    } on PlaylistException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Yayın akışını arka planda yükler; kanal listesi beklemez. Diskte kayıt
  /// varsa önce o gösterilir, gerekirse güncel hali ardından gelir. Yenileme
  /// sırasında eldeki akış ekranda kalır.
  Future<void> _loadEpg(Playlist playlist) async {
    setState(() {
      _epgError = null;
      _epgLoading = true;
    });
    // Yükleme sürerken kaynak değiştiyse sonucu at.
    bool stale() => !mounted || !identical(_playlist, playlist);
    try {
      await for (final epg in loadEpg(playlist)) {
        if (stale()) return;
        setState(() {
          _epg = epg;
          _now = DateTime.now();
        });
      }
    } catch (e) {
      if (stale()) return;
      setState(() => _epgError = e);
    } finally {
      if (!stale()) {
        setState(() {
          _epgLoading = false;
          _epgCheckedAt = DateTime.now();
        });
      }
    }
  }

  /// Kanalı seçili karede açar; hiç kare yoksa ilkini oluşturur.
  void _play(Channel channel) {
    final active = _active;
    if (active == null) {
      _addSlot(channel);
    } else {
      setState(() => active.play(channel));
      _remember(channel);
    }
  }

  void _remember(Channel channel) {
    setState(() {
      _recents = [
        channel.key,
        for (final k in _recents)
          if (k != channel.key) k,
      ].take(_maxRecents).toList();
    });
    _recentsStore.writeList(_source, _recents);
  }

  /// Kanalı yeni bir karede açar ve sesi ona verir.
  void _addSlot(Channel channel) {
    if (_slots.length >= _maxSlots) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.maxSlotsReached(_maxSlots)),
      ));
      return;
    }
    final slot = StreamSlot(channel)..muted = appMuted.value;
    _slots.add(slot);
    _activate(slot);
    _remember(channel);
  }

  void _activate(StreamSlot slot) {
    setState(() => _active = slot);
    for (final s in _slots) {
      s.backgrounded = !identical(s, slot);
    }
  }

  void _toggleMute() => appMuted.value = !appMuted.value;

  void _applyMute() {
    setState(() {});
    for (final s in _slots) {
      s.muted = appMuted.value;
    }
  }

  void _toggleFocus(StreamSlot slot) {
    setState(() => _focus = identical(_focus, slot) ? null : slot);
    _activate(slot);
  }

  void _closeSlot(StreamSlot slot) {
    setState(() {
      _slots.remove(slot);
      if (identical(_focus, slot)) _focus = null;
    });
    if (identical(_active, slot)) {
      final next = _slots.lastOrNull;
      if (next == null) {
        setState(() => _active = null);
      } else {
        _activate(next);
      }
    }
    // Karenin widget'ları ağaçtan çıktıktan sonra kapat.
    WidgetsBinding.instance.addPostFrameCallback((_) => slot.dispose());
  }

  bool _isPlaying(Channel channel) =>
      _slots.any((s) => identical(s.channel, channel));

  Future<void> _showSchedule(Channel channel) async {
    final source = _source;
    final canArchive = source is XtreamSource && channel.id != null;
    final programme = await showScheduleDialog(
      context,
      channelName: channel.name,
      programmes: _epg?.programmesFor(channel.tvgId) ?? const [],
      archiveDays: canArchive ? channel.archiveDays : 0,
    );
    if (programme != null && source is XtreamSource && mounted) {
      await _playArchive(source, channel, programme);
    }
  }

  /// Geçmiş yayını ayrı oynatıcıda açar. Sağlayıcının bağlantı sınırı
  /// dolmasın diye canlı yayınlar kapanır, dönünce seçili kanal yeniden
  /// açılır.
  Future<void> _playArchive(
      XtreamSource source, Channel channel, Programme programme) async {
    final resume = _current;
    _stopLive();
    final l = context.l10n;
    final start = programme.start.toLocal();
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => VodPlayerScreen(
        title: programme.title,
        subtitle: '${channel.name} · ${l.weekdayDate(start)} '
            '${l.time(start)}',
        url: catchupUrl(
          source,
          streamId: channel.id!,
          start: programme.start,
          duration: programme.stop.difference(programme.start),
          serverOffset: _playlist?.serverOffset,
        ),
        source: source,
      ),
    ));
    if (mounted && resume != null && _section == _Section.live) {
      _play(resume);
    }
  }

  /// Tüm kareleri kapatır.
  void _stopLive() {
    final slots = [..._slots];
    if (slots.isEmpty) return;
    setState(() {
      _slots.clear();
      _active = _focus = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final s in slots) {
        s.dispose();
      }
    });
  }

  void _setSection(_Section section) {
    if (section == _section) return;
    // Başka bölümdeyken canlı yayın bağlantı hakkını tutmasın.
    if (section != _Section.live) _stopLive();
    if (section == _Section.home) _loadContinue();
    setState(() => _section = section);
  }

  static CategoryKind _categoryKind(VodKind kind) =>
      kind == VodKind.movie ? CategoryKind.movies : CategoryKind.series;

  Future<void> _loadVodLayouts() async {
    for (final kind in VodKind.values) {
      final layout = await _layoutStore.read(_source, _categoryKind(kind));
      if (!mounted) return;
      setState(() => _vodLayouts[kind] = layout);
    }
  }

  void _setVodLayout(VodKind kind, CategoryLayout layout) {
    setState(() => _vodLayouts[kind] = layout);
    _layoutStore.write(_source, _categoryKind(kind), layout);
  }

  Future<VodCatalog> _catalog(VodKind kind) =>
      _catalogs[kind] ??= loadVodCatalog(_source as XtreamSource, kind);

  Future<void> _loadContinue() async {
    final list = continueWatchingOf(await _progressStore.entries(_source));
    if (mounted) setState(() => _continue = list);
  }

  Future<void> _resume(WatchEntry entry) async {
    final meta = entry.meta!;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => VodPlayerScreen(
        title: meta.title,
        subtitle: watchSubtitle(context.l10n, meta),
        url: watchUrl(_source as XtreamSource, meta),
        source: _source,
        progressKey: entry.key,
        progressMeta: meta,
        progressStore: _progressStore,
        start: entry.progress.position,
      ),
    ));
    _loadContinue();
  }

  /// Ana sayfa ya da aramadan kanal açınca Canlı TV'ye geçer.
  void _watchChannel(Channel channel) {
    _setSection(_Section.live);
    _play(channel);
  }

  void _openGroup(String group) {
    setState(() {
      _group = group;
      _query = '';
    });
    _setSection(_Section.live);
  }

  Future<void> _openVod(VodItem item) async {
    final progress = await _progressStore.read(_source);
    if (!mounted) return;
    await openVodItem(
      context,
      source: _source as XtreamSource,
      item: item,
      progressStore: _progressStore,
      progress: progress[item.key],
    );
    _loadContinue();
  }

  Widget _homeBody(Playlist? playlist) {
    final l = context.l10n;
    final xtream = _source is XtreamSource;
    final byKey = _byKey;
    return HomeView(
      listName: widget.saved.name,
      now: _now,
      channelsLoading: playlist == null && _loading,
      continueWatching: xtream ? _continue : const [],
      recentChannels: [
        for (final k in _recents) ?byKey[k],
      ],
      favoriteGroups: playlist == null
          ? const []
          : [
              for (final g in _favoriteGroups)
                if (playlist.groups.contains(g) && !_groupLayout.isHidden(g)) g,
            ],
      groupCounts: playlist?.groupCounts ?? const {},
      nowOn: (c) => _epg?.current(c.tvgId, _now),
      onResume: _resume,
      onPlayChannel: _watchChannel,
      onOpenGroup: _openGroup,
      shortcuts: [
        (
          icon: Icons.live_tv_rounded,
          label: l.sectionLive,
          detail:
              playlist == null ? null : l.channelCount(_visibleChannelCount(playlist)),
          onTap: () => _setSection(_Section.live),
        ),
        if (xtream) ...[
          (
            icon: Icons.movie_rounded,
            label: l.sectionMovies,
            detail: null,
            onTap: () => _setSection(_Section.movies),
          ),
          (
            icon: Icons.video_library_rounded,
            label: l.sectionSeries,
            detail: null,
            onTap: () => _setSection(_Section.series),
          ),
        ],
        (
          icon: Icons.search_rounded,
          label: l.sectionSearch,
          detail: xtream ? l.searchShortcutAll : l.searchShortcutChannels,
          onTap: () => _setSection(_Section.search),
        ),
      ],
    );
  }

  Widget _vodBody(XtreamSource source) {
    final kind =
        _section == _Section.movies ? VodKind.movie : VodKind.series;
    return VodBrowser(
      key: ValueKey(kind),
      source: source,
      kind: kind,
      catalog: _catalog(kind),
      layout: _vodLayouts[kind] ?? CategoryLayout.empty,
      onLayoutChanged: (layout) => _setVodLayout(kind, layout),
      onRetry: () => setState(() => _catalogs.remove(kind)),
      progressStore: _progressStore,
    );
  }

  bool _hasSchedule(Channel? channel) =>
      channel != null &&
      (_epg?.programmesFor(channel.tvgId).isNotEmpty ?? false);

  Future<void> _showChannelMenu(Channel channel, Offset position) async {
    final canAdd = _slots.isNotEmpty &&
        _slots.length < _maxSlots &&
        !_isPlaying(channel);
    final l = context.l10n;
    final action = await showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          value: () => _play(channel),
          child: ListTile(
            leading: const Icon(Icons.play_arrow),
            title: Text(l.play),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (canAdd)
          PopupMenuItem(
            value: () => _addSlot(channel),
            child: ListTile(
              leading: const Icon(Icons.add_to_queue),
              title: Text(l.watchSideBySide),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (_hasSchedule(channel))
          PopupMenuItem(
            value: () => _showSchedule(channel),
            child: ListTile(
              leading: const Icon(Icons.calendar_view_day),
              title: Text(l.schedule),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
    action?.call();
  }

  /// Gizlenen kategorilerin kanalları düşülmüş sayı.
  int _visibleChannelCount(Playlist playlist) =>
      playlist.channelCount -
      _groupLayout.hidden
          .fold(0, (sum, g) => sum + (playlist.groupCounts[g] ?? 0));

  Future<void> _editGroups(Playlist playlist) async {
    final l = context.l10n;
    final layout = await showCategoryEditor(
      context,
      entries: [
        for (final g in playlist.groups)
          (key: g, label: l.group(g), count: playlist.groupCounts[g]),
      ],
      layout: _groupLayout,
    );
    if (layout == null || !mounted) return;
    setState(() {
      _groupLayout = layout;
      if (_group case final g? when layout.isHidden(g)) _group = null;
    });
    await _layoutStore.write(_source, CategoryKind.live, layout);
  }

  void _toggleFavoriteGroup(String group) {
    setState(() {
      _favoriteGroups = _favoriteGroups.contains(group)
          ? [
              for (final g in _favoriteGroups)
                if (g != group) g,
            ]
          : [..._favoriteGroups, group];
    });
    _groupsStore.writeList(_source, _favoriteGroups);
  }

  /// Uygulama geneli kısayollar: PgUp/PgDn kanal, Backspace önceki kanal,
  /// M sessiz, F tam ekran. Oynatıcının kendi kısayolları (boşluk, oklarla
  /// ses) video odaktayken ayrıca çalışır.
  bool _onKey(KeyEvent event) {
    if (event is KeyUpEvent || !mounted || _section != _Section.live) {
      return false;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed) {
      return false;
    }
    final active = _active;
    final fullscreen = _isFullscreen(active);
    // Pencere, menü ya da yazı alanı açıkken karışma.
    if (!fullscreen && !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return false;
    }
    if (_typing()) return false;
    final key = event.logicalKey;
    final repeat = event is KeyRepeatEvent;
    if (key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.channelDown) {
      _step(1);
    } else if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.channelUp) {
      _step(-1);
    } else if (repeat) {
      return false;
    } else if (key == LogicalKeyboardKey.backspace && active != null) {
      final previous = active.previous;
      if (previous == null) return false;
      _play(previous);
    } else if (key == LogicalKeyboardKey.keyM && active != null) {
      _toggleMute();
    } else if (key == LogicalKeyboardKey.keyF &&
        active != null &&
        _slots.length == 1 &&
        !_videoFocused()) {
      // Video odaktaysa oynatıcı F'yi kendisi işler.
      active.videoKey.currentState?.toggleFullscreen();
    } else {
      return false;
    }
    return true;
  }

  static bool _isFullscreen(StreamSlot? slot) {
    try {
      return slot?.videoKey.currentState?.isFullscreen() ?? false;
    } catch (_) {
      return false;
    }
  }

  static bool _typing() {
    final context = FocusManager.instance.primaryFocus?.context;
    return context != null &&
        (context.widget is EditableText ||
            context.findAncestorWidgetOfExactType<EditableText>() != null);
  }

  static bool _videoFocused() =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<VideoState>() !=
      null;

  /// Görünen listede sonraki/önceki kanala geçer; uçlarda başa sarar.
  void _step(int direction) {
    final playlist = _playlist;
    if (playlist == null) return;
    final channels = [
      for (final c in _visibleChannels(playlist))
        if (!c.isSeparator) c,
    ];
    if (channels.isEmpty) return;
    final i = channels.indexWhere((c) => identical(c, _current));
    final next = i < 0
        ? channels.first
        : channels[(i + direction) % channels.length];
    _play(next);
  }

  List<Channel> _visibleChannels(Playlist playlist) {
    final query = searchKey(_query);
    if (_group == _recentsGroup) {
      return [
        for (final k in _recents)
          if (_byKey[k] case final c?)
            if (query.isEmpty || searchKey(c.name).contains(query)) c,
      ];
    }
    final hidden = _groupLayout.hidden;
    return playlist.channels.where((c) {
      final group = c.group ?? Playlist.ungrouped;
      if (_group != null ? group != _group : hidden.contains(group)) {
        return false;
      }
      // Aramada başlık satırları anlamsız.
      return query.isEmpty ||
          (!c.isSeparator && searchKey(c.name).contains(query));
    }).toList();
  }

  /// Tek kare tam alan; birden fazlası ızgara ya da büyütülmüş kare ve
  /// altta şerit (Discord'daki gibi).
  Widget _players() {
    if (_slots.length == 1) return _slotView(_slots.single, single: true);
    Widget cell(StreamSlot slot) => Padding(
          padding: const EdgeInsets.all(2),
          child: _slotView(slot, single: false),
        );
    final focus = _focus;
    if (focus != null) {
      return ColoredBox(
        color: AppColors.of(context).bg,
        child: Column(
          children: [
            Expanded(child: cell(focus)),
            SizedBox(
              height: 128,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final s in _slots)
                    if (!identical(s, focus))
                      AspectRatio(aspectRatio: 16 / 9, child: cell(s)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final rows = [
      for (var i = 0; i < _slots.length; i += 2)
        _slots.sublist(i, (i + 2).clamp(0, _slots.length)),
    ];
    return ColoredBox(
      color: AppColors.of(context).bg,
      child: Column(
        children: [
          for (final row in rows)
            Expanded(
              child: Row(
                children: [
                  for (final s in row) Expanded(child: cell(s)),
                  // Tek kalan kare yarım genişlikte kalsın.
                  if (row.length == 1 && rows.length > 1)
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _slotView(StreamSlot slot, {required bool single}) {
    final active = identical(slot, _active);
    final c = AppColors.of(context);
    return KeyedSubtree(
      key: GlobalObjectKey(slot),
      child: GestureDetector(
        onTap: single ? null : () => _activate(slot),
        onDoubleTap: single ? null : () => _toggleFocus(slot),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: single
                ? null
                : Border.all(
                    color: active ? c.accent : Colors.transparent,
                    width: 2,
                  ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MaterialDesktopVideoControlsTheme(
                normal: liveControls,
                fullscreen: liveControls,
                child: Video(
                  key: slot.videoKey,
                  controller: slot.controller,
                  controls: single ? AdaptiveVideoControls : NoVideoControls,
                ),
              ),
              ListenableBuilder(
                listenable: slot.watchdog,
                builder: (context, _) => _StallOverlay(
                  watchdog: slot.watchdog,
                  onRetry: () => slot.play(slot.channel),
                ),
              ),
              if (!single)
                _SlotBar(
                  channel: slot.channel,
                  active: active,
                  muted: appMuted.value,
                  focused: identical(slot, _focus),
                  onFocus: () => _toggleFocus(slot),
                  onClose: () => _closeSlot(slot),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _playlist;
    final xtream = _source is XtreamSource;
    final l = context.l10n;
    final Widget body;
    if (_section == _Section.home) {
      body = _homeBody(playlist);
    } else if (_section == _Section.search) {
      body = SearchView(
        playlist: playlist,
        hiddenGroups: _groupLayout.hidden,
        hiddenVod: {
          for (final MapEntry(:key, :value) in _vodLayouts.entries)
            key: value.hidden,
        },
        catalog: xtream ? _catalog : null,
        nowOn: (c) => _epg?.current(c.tvgId, _now),
        now: _now,
        onPlayChannel: _watchChannel,
        onOpenVod: _openVod,
      );
    } else if (_section != _Section.live) {
      // Katalog kanal listesinden bağımsız; liste yüklenirken de açılabilir.
      body = _vodBody(_source as XtreamSource);
    } else if (playlist == null) {
      body = _loading || _error == null
          ? const _LiveSkeleton()
          : _LoadError(message: l.error(_error!), onRetry: _load);
    } else {
      body = _liveBody(playlist, _visibleChannels(playlist),
          _epg?.current(_current?.tvgId, _now));
    }
    return Scaffold(
      body: Row(
        children: [
          AppRail<_Section>(
            selected: _section,
            onSelected: _setSection,
            items: [
              RailItem(
                value: _Section.home,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: l.sectionHome,
              ),
              RailItem(
                value: _Section.live,
                icon: Icons.live_tv_outlined,
                selectedIcon: Icons.live_tv,
                label: l.sectionLive,
              ),
              if (xtream) ...[
                RailItem(
                  value: _Section.movies,
                  icon: Icons.movie_outlined,
                  selectedIcon: Icons.movie,
                  label: l.sectionMovies,
                ),
                RailItem(
                  value: _Section.series,
                  icon: Icons.video_library_outlined,
                  selectedIcon: Icons.video_library,
                  label: l.sectionSeries,
                ),
              ],
              RailItem(
                value: _Section.search,
                icon: Icons.search,
                selectedIcon: Icons.search,
                label: l.sectionSearch,
              ),
            ],
            footer: [
              RailButton(
                icon: Icons.settings_outlined,
                label: l.sectionSettings,
                onTap: () => openSettings(context),
              ),
              RailButton(
                icon: Icons.layers_outlined,
                label: l.sectionLists,
                tooltip: l.backToLists,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          Expanded(
            child: FocusTraversalGroup(
              child: Column(
                children: [
                  _topBar(context, playlist),
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sayfa başlığı ve oynatıcıya ait eylemler.
  Widget _topBar(BuildContext context, Playlist? playlist) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final expiresAt = playlist?.expiresAt;
    final l = context.l10n;
    final title = switch (_section) {
      _Section.home => l.sectionHome,
      _Section.search => l.sectionSearch,
      _Section.live => _current?.name ?? l.sectionLive,
      _Section.movies => l.sectionMovies,
      _Section.series => l.sectionSeries,
    };
    return Container(
      height: 64,
      padding: const EdgeInsetsDirectional.only(start: Space.lg, end: Space.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.upper(widget.saved.name),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: c.fgMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_section == _Section.live) ...[
            if (_active case final active?)
              TrackMenus(key: ObjectKey(active), player: active.player),
            if (appMuted.value && _slots.isNotEmpty)
              IconButton(
                tooltip: l.unmuteShortcut,
                icon: const Icon(Icons.volume_off),
                onPressed: _toggleMute,
              ),
            if (_hasSchedule(_current))
              IconButton(
                tooltip: l.schedule,
                icon: const Icon(Icons.calendar_view_day),
                onPressed: () => _showSchedule(_current!),
              ),
          ],
          if (_epgLoading)
            _StatusPill(
              leading: const SizedBox.square(
                dimension: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: l.epgUpdating,
            )
          else if (_epgError case final error?)
            Tooltip(
              message: l.error(error),
              child: _StatusPill(
                leading: Icon(Icons.event_busy,
                    size: IconSizes.sm, color: c.warning),
                label: l.epgFailed,
              ),
            ),
          if (expiresAt != null)
            _StatusPill(
              leading: Icon(Icons.event_outlined,
                  size: IconSizes.sm,
                  color: _expiresSoon(expiresAt) ? c.warning : c.fgMuted),
              label: l.expiresOn(l.date(expiresAt)),
              color: _expiresSoon(expiresAt) ? c.warning : null,
            ),
        ],
      ),
    );
  }

  static bool _expiresSoon(DateTime expiresAt) =>
      expiresAt.difference(DateTime.now()) < const Duration(days: 7);

  Widget _liveBody(Playlist playlist, List<Channel> channels, Programme? onAir) {
    final l = context.l10n;
    return Row(
      children: [
        SizedBox(
          width: 248,
          child: _GroupList(
            groups: _groupLayout.visible(playlist.groups, (g) => g),
            hiddenCount: _groupLayout.hidden.length,
            onEdit: () => _editGroups(playlist),
            counts: playlist.groupCounts,
            selected: _group,
            specials: [
              (null, l.allChannels, Icons.apps, _visibleChannelCount(playlist)),
              (_recentsGroup, l.recentlyWatched, Icons.history,
                  _recents.length),
            ],
            favoriteGroups: _favoriteGroups,
            onToggleFavorite: _toggleFavoriteGroup,
            onSelected: (g) => setState(() => _group = g),
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 340,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Space.sm, Space.sm, Space.sm, Space.xxs),
                child: SearchField(
                  hint: l.searchChannels,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: channels.isEmpty
                    ? EmptyState(
                        icon: _group == _recentsGroup
                            ? Icons.history
                            : Icons.search_off,
                        title: _group == _recentsGroup && _query.isEmpty
                            ? l.noRecentChannelsTitle
                            : l.noChannelFound,
                        message: _group == _recentsGroup && _query.isEmpty
                            ? l.noRecentChannelsMessage
                            : l.changeSearchOrCategory,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: Space.md),
                        itemCount: channels.length,
                        itemExtentBuilder: (i, _) =>
                            i < channels.length && channels[i].isSeparator
                                ? 40
                                : ChannelTile.height + 4,
                        itemBuilder: (context, i) {
                          final channel = channels[i];
                          if (channel.isSeparator) {
                            return SectionHeader(channel.separatorLabel!,
                                padding: const EdgeInsets.fromLTRB(
                                    Space.md, Space.md, Space.md, 4));
                          }
                          final programme =
                              _epg?.current(channel.tvgId, _now);
                          return ChannelTile(
                            name: channel.name,
                            logo: channel.logo,
                            programme: programme?.title,
                            progress: programme?.progress(_now),
                            playing: _isPlaying(channel),
                            selected: identical(channel, _current),
                            onTap: () => _play(channel),
                            onSecondaryTapUp: (d) =>
                                _showChannelMenu(channel, d.globalPosition),
                            action: _slots.isNotEmpty && !_isPlaying(channel)
                                ? IconButton(
                                    tooltip: _slots.length < _maxSlots
                                        ? l.watchSideBySide
                                        : l.maxSlotsShort(_maxSlots),
                                    icon: const Icon(Icons.add_to_queue,
                                        size: IconSizes.md),
                                    onPressed: _slots.length < _maxSlots
                                        ? () => _addSlot(channel)
                                        : null,
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _slots.isEmpty
              ? const _NoChannel()
              : Column(
                  children: [
                    Expanded(child: _players()),
                    if (onAir != null)
                      _NowNext(
                        current: onAir,
                        next: _epg!.next(_current!.tvgId, _now),
                        now: _now,
                        onSchedule: () => _showSchedule(_current!),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Grup listesinin başındaki sabit girdiler: (anahtar, etiket, ikon, sayı).
typedef _Special = (String? key, String label, IconData? icon, int? count);

/// Grup listesindeki satır: sabit girdi, başlık ya da kategori.
typedef _GroupRow = ({
  String? key,
  String label,
  IconData? icon,
  int? count,
  bool header,
  bool group,
});

class _GroupList extends StatefulWidget {
  const _GroupList({
    required this.groups,
    required this.hiddenCount,
    required this.onEdit,
    required this.counts,
    required this.selected,
    required this.specials,
    required this.favoriteGroups,
    required this.onToggleFavorite,
    required this.onSelected,
  });

  final List<String> groups;
  final int hiddenCount;
  final VoidCallback onEdit;
  final Map<String, int> counts;
  final String? selected;
  final List<_Special> specials;
  final List<String> favoriteGroups;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<String?> onSelected;

  @override
  State<_GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<_GroupList> {
  /// "Tüm kategoriler" başlığı; yanında düzenleme düğmesi durur.
  static const _allHeader = '\u0000all';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l = context.l10n;
    final query = searchKey(_query.trim());
    final groups = query.isEmpty
        ? widget.groups
        : widget.groups.where((g) => searchKey(g).contains(query)).toList();
    final favorites = {...widget.favoriteGroups};
    // Listede artık olmayan favoriler gösterilmez.
    final pinned = query.isEmpty
        ? widget.favoriteGroups.where(widget.groups.contains).toList()
        : const <String>[];
    // Aramada sabit girdiler ve başlıklar gizlenir.
    final rows = <_GroupRow>[
      if (query.isEmpty)
        for (final (key, label, icon, count) in widget.specials)
          (key: key, label: label, icon: icon, count: count, header: false,
              group: false),
      if (pinned.isNotEmpty) ...[
        (key: null, label: l.favoritePackages, icon: null, count: null,
            header: true, group: false),
        for (final g in pinned)
          (key: g, label: l.group(g), icon: null, count: widget.counts[g],
              header: false, group: true),
      ],
      if (query.isEmpty)
        (key: _allHeader, label: l.allCategories, icon: null, count: null,
            header: true, group: false),
      for (final g in groups)
        (key: g, label: l.group(g), icon: null, count: widget.counts[g],
            header: false, group: true),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.sm, Space.sm, Space.sm, Space.xxs),
          child: SearchField(
            hint: l.searchCategories,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Text(l.noMatchingCategory,
                      style: Theme.of(context).textTheme.bodySmall),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: Space.md),
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    if (row.header) {
                      return SectionHeader(
                        row.label,
                        padding: EditCategoriesButton.headerPadding,
                        trailing: row.key == _allHeader
                            ? EditCategoriesButton(
                                hiddenCount: widget.hiddenCount,
                                onPressed: widget.onEdit,
                              )
                            : null,
                      );
                    }
                    final key = row.key;
                    final favorite = key != null && favorites.contains(key);
                    return NavRow(
                      label: row.label,
                      leading: row.icon,
                      count: row.count,
                      selected: key == widget.selected,
                      onTap: () => widget.onSelected(key),
                      showTrailing: favorite,
                      trailing: row.group
                          ? IconButton(
                              tooltip: favorite
                                  ? l.removeFromFavoritePackages
                                  : l.addToFavoritePackages,
                              iconSize: IconSizes.md,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(favorite
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded),
                              color: favorite ? c.accent : c.fgMuted,
                              onPressed: () => widget.onToggleFavorite(key!),
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Oynayan kanalın şu anki ve sıradaki programı.
class _NowNext extends StatelessWidget {
  const _NowNext({
    required this.current,
    required this.next,
    required this.now,
    required this.onSchedule,
  });

  final Programme current;
  final Programme? next;
  final DateTime now;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    final next = this.next;
    final remaining = current.stop.difference(now).inMinutes;
    const tabular = [FontFeature.tabularFigures()];
    final time = theme.textTheme.labelMedium
        ?.copyWith(color: c.fgMuted, fontFeatures: tabular);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      padding:
          const EdgeInsetsDirectional.fromSTEB(Space.lg, Space.md, Space.md, Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LiveBadge(label: l.nowBadge),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  current.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Space.sm),
              OutlinedButton.icon(
                onPressed: onSchedule,
                icon: const Icon(Icons.calendar_view_day, size: IconSizes.sm),
                label: Text(l.schedule),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Row(
            children: [
              Text(l.time(current.start), style: time),
              const SizedBox(width: Space.sm),
              Expanded(
                child: ClipRRect(
                  borderRadius: Radii.smAll,
                  child: LinearProgressIndicator(
                    value: current.progress(now),
                    minHeight: 4,
                    backgroundColor: c.border,
                  ),
                ),
              ),
              const SizedBox(width: Space.sm),
              Text(l.time(current.stop), style: time),
              if (remaining > 0) ...[
                const SizedBox(width: Space.sm),
                Text(l.minutesLeft(remaining), style: time),
              ],
            ],
          ),
          if (current.description case final desc?) ...[
            const SizedBox(height: Space.sm),
            Text(
              desc,
              style: theme.textTheme.bodyMedium?.copyWith(color: c.fgMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (next != null) ...[
            const SizedBox(height: Space.sm),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: '${l.nextLabel}  ',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: c.fgMuted)),
                TextSpan(text: '${l.time(next.start)}  ', style: time),
                TextSpan(
                    text: next.title,
                    style: theme.textTheme.bodySmall?.copyWith(color: c.fg)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Oynatıcı boşken: ne yapılacağı ve kısayollar.
class _NoChannel extends StatelessWidget {
  const _NoChannel();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l = context.l10n;
    final label =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: c.fgMuted);
    Widget hint(List<String> keys, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  children: [for (final k in keys) Kbd(k)],
                ),
              ),
              const SizedBox(width: Space.sm),
              SizedBox(width: 140, child: Text(text, style: label)),
            ],
          ),
        );
    return EmptyState(
      icon: Icons.live_tv_outlined,
      title: l.pickChannelTitle,
      message: l.pickChannelMessage,
      footer: Column(
        children: [
          hint(['PgUp', 'PgDn'], l.hintChangeChannel),
          hint(['Backspace'], l.hintPreviousChannel),
          hint(['M'], l.hintMute),
          hint(['F'], l.hintFullscreen),
        ],
      ),
    );
  }
}

/// Çoklu izlemede karenin üstündeki şerit: kanal adı, ses durumu, büyüt ve
/// kapat.
class _SlotBar extends StatelessWidget {
  const _SlotBar({
    required this.channel,
    required this.active,
    required this.muted,
    required this.focused,
    required this.onFocus,
    required this.onClose,
  });

  final Channel channel;
  final bool active;
  final bool muted;
  final bool focused;
  final VoidCallback onFocus;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final audible = active && !muted;
    return Align(
      alignment: Alignment.topCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.scrim, Colors.transparent],
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(Space.sm, 6, Space.xxs, Space.md),
          child: Row(
            children: [
              Tooltip(
                message: audible ? context.l10n.audioInThisTile : context.l10n.muted,
                child: Icon(audible ? Icons.volume_up : Icons.volume_off,
                    size: IconSizes.sm, color: audible ? c.accent : c.fgMuted),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  channel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: active ? c.fg : c.fgMuted),
                ),
              ),
              IconButton(
                tooltip: focused ? context.l10n.backToGrid : context.l10n.enlarge,
                iconSize: IconSizes.md,
                visualDensity: VisualDensity.compact,
                icon: Icon(focused ? Icons.grid_view : Icons.open_in_full),
                onPressed: onFocus,
              ),
              IconButton(
                tooltip: context.l10n.closeTile,
                iconSize: IconSizes.md,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yayın durunca yeniden bağlanma durumu ya da vazgeçildiyse hata.
class _StallOverlay extends StatelessWidget {
  const _StallOverlay({required this.watchdog, required this.onRetry});

  final StallWatchdog watchdog;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    switch (watchdog.status) {
      case StallStatus.ok:
        return const SizedBox.shrink();
      case StallStatus.reconnecting:
        return IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surfaceRaised.withValues(alpha: 0.92),
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  border: Border.all(color: c.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Space.md, vertical: Space.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.l10n.reconnecting(
                            watchdog.attempt, watchdog.maxRetries),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case StallStatus.failed:
        return ColoredBox(
          color: c.scrim,
          child: EmptyState(
            icon: Icons.signal_wifi_bad,
            tone: c.danger,
            title: context.l10n.channelFailedTitle,
            message: context.l10n.channelFailedMessage,
            actions: [
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.tryAgain),
              ),
            ],
          ),
        );
    }
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      tone: AppColors.of(context).danger,
      title: context.l10n.listFailedTitle,
      message: message,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(context.l10n.backToLists),
        ),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.retry),
        ),
      ],
    );
  }
}

/// Kanal listesi yüklenirken ekranın iskeleti.
class _LiveSkeleton extends StatelessWidget {
  const _LiveSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget column(double width, Widget Function(int) row, int count) =>
        SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 40, radius: Radii.mdAll),
                const SizedBox(height: Space.md),
                for (var i = 0; i < count; i++) row(i),
              ],
            ),
          ),
        );
    return Semantics(
      label: context.l10n.loadingChannels,
      child: ClipRect(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            column(
              260,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Skeleton(height: 14, width: 120.0 + (i * 37) % 90),
              ),
              14,
            ),
            VerticalDivider(width: 1, color: c.border),
            column(
              360,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Skeleton(width: 44, height: 44, radius: Radii.mdAll),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Skeleton(height: 12, width: 140.0 + (i * 53) % 80),
                          const SizedBox(height: 8),
                          const Skeleton(height: 10, width: 110),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              9,
            ),
            VerticalDivider(width: 1, color: c.border),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: Space.md),
                    Text(context.l10n.loadingChannels),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Üst çubuktaki küçük durum etiketi.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.leading, required this.label, this.color});

  final Widget leading;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: Space.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          border: Border.all(color: c.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Space.sm, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 6),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: color ?? c.fgMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

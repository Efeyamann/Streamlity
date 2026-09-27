import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../models/epg.dart';
import '../models/playlist.dart';
import '../ui/tokens.dart';
import '../ui/widgets/channel_tile.dart';
import '../ui/widgets/common.dart';
import 'schedule_dialog.dart' show canWatchFromArchive;

/// Rehberin zaman aralığı: [pastDays] gün öncesinin yerel gece yarısından en
/// geç biten programa kadar. Bitiş en az [now]'dan 6 saat sonra, en fazla
/// [futureDays] gün sonrasının sonu; saat başına yuvarlanır.
({DateTime start, DateTime end}) guideRange(
  Iterable<List<Programme>> programmes,
  DateTime now, {
  int pastDays = 0,
  int futureDays = 7,
}) {
  final local = now.toLocal();
  final start = DateTime(local.year, local.month, local.day - pastDays);
  final limit = DateTime(local.year, local.month, local.day + futureDays + 1);
  var end = now.add(const Duration(hours: 6));
  for (final list in programmes) {
    if (list.isNotEmpty && list.last.stop.isAfter(end)) end = list.last.stop;
  }
  if (end.isAfter(limit)) end = limit;
  final e = end.toLocal();
  final hour = DateTime(e.year, e.month, e.day, e.hour);
  return (
    start: start,
    end: hour.isBefore(e) ? hour.add(const Duration(hours: 1)) : hour,
  );
}

/// Başlangıca göre sıralı [list]'te [from]–[to] aralığına değen programların
/// indeks aralığı (başlangıç dahil, bitiş hariç).
(int, int) programmesBetween(
    List<Programme> list, DateTime from, DateTime to) {
  var lo = 0, hi = list.length;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (list[mid].start.isBefore(from)) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  // Aralıktan önce başlayıp içine taşanlar.
  var first = lo;
  while (first > 0 && list[first - 1].stop.isAfter(from)) {
    first--;
  }
  var last = lo;
  while (last < list.length && list[last].start.isBefore(to)) {
    last++;
  }
  return (first, last);
}

/// Izgara rehber: kanallar satırlarda, zaman ekseni sütunlarda. Satırlar
/// dikey listede tembel kurulur; her satır yalnız görünen zaman aralığındaki
/// programları çizer. Yatay konum tek bir kaydırıcıda tutulur (alttaki
/// çubuk, Shift+tekerlek ya da dokunmatik yüzey).
///
/// Yayındaki programa tıklamak kanalı açar; arşiv süresindeki geçmiş
/// programlar geçmiş yayından oynar. Sağ tık diğer seçenekleri gösterir.
class GuideView extends StatefulWidget {
  const GuideView({
    super.key,
    required this.channels,
    required this.epg,
    required this.now,
    required this.archiveDays,
    required this.onWatch,
    required this.onArchive,
    required this.onSchedule,
    this.scrollKey,
  });

  static const double channelWidth = 200;
  static const double rowHeight = 60;
  static const double headerHeight = 36;
  static const double pixelsPerMinute = 5;

  /// Başlık satırı olmayan kanallar.
  final List<Channel> channels;
  final Epg epg;
  final DateTime now;

  /// Kanalın geçmiş yayın süresi (gün); izlenemiyorsa 0.
  final int Function(Channel channel) archiveDays;
  final ValueChanged<Channel> onWatch;
  final void Function(Channel channel, Programme programme) onArchive;
  final ValueChanged<Channel> onSchedule;

  /// Değişince (ör. başka kategori) liste başa döner; yatay konum korunur.
  final Object? scrollKey;

  @override
  State<GuideView> createState() => _GuideViewState();
}

/// Ayrıntı panelinde gösterilen program.
typedef _Detail = ({Channel channel, Programme programme});

class _GuideViewState extends State<GuideView> {
  static const _ppm = GuideView.pixelsPerMinute;

  late DateTime _start;
  late DateTime _end;
  late final ScrollController _h;
  final _v = ScrollController();

  /// Fareyle üzerine gelinen ya da klavyeyle odaklanan program. Izgara
  /// yeniden kurulmasın diye ayrı dinlenir.
  final _detail = ValueNotifier<_Detail?>(null);

  /// Programların çizildiği alanın genişliği; son yerleşimden.
  double _stripWidth = 0;

  @override
  void initState() {
    super.initState();
    _updateRange();
    // Açılışta yarım saat öncesinden başla.
    _h = ScrollController(
      initialScrollOffset: math.max(
          0, _x(widget.now.subtract(const Duration(minutes: 30)))),
    );
  }

  @override
  void didUpdateWidget(GuideView old) {
    super.didUpdateWidget(old);
    final start = _start;
    _updateRange();
    // Gün dönünce aralığın başı kayar; ekrandaki saat yerinde kalsın.
    if (_start != start && _h.hasClients) {
      _h.jumpTo(math.max(0, _h.offset - _minutes(_start, start) * _ppm));
    }
    if (old.scrollKey != widget.scrollKey && _v.hasClients) _v.jumpTo(0);
    final detail = _detail.value;
    if (detail != null && !widget.channels.contains(detail.channel)) {
      _detail.value = null;
    }
  }

  @override
  void dispose() {
    _h.dispose();
    _v.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _updateRange() {
    var pastDays = 0;
    for (final c in widget.channels) {
      pastDays = math.max(pastDays, widget.archiveDays(c));
    }
    final range = guideRange(
      [for (final c in widget.channels) widget.epg.programmesFor(c.tvgId)],
      widget.now,
      pastDays: math.min(pastDays, 7),
    );
    _start = range.start;
    _end = range.end;
  }

  static double _minutes(DateTime from, DateTime to) =>
      to.difference(from).inSeconds / 60;

  /// Zamanın aralığın başından uzaklığı (piksel).
  double _x(DateTime t) => _minutes(_start, t) * _ppm;

  double get _totalWidth => _x(_end);

  double get _offset => _h.hasClients ? _h.offset : _h.initialScrollOffset;

  /// Görünen alanın ortasındaki an; gün seçicinin etiketi için.
  DateTime get _viewCenter => _start.add(Duration(
      seconds: ((_offset + _stripWidth / 2) / _ppm * 60).round()));

  void _scrollTo(double offset) {
    if (!_h.hasClients) return;
    final target = offset.clamp(0.0, _h.position.maxScrollExtent);
    final duration = Motion.of(context).base;
    if (duration == Duration.zero) {
      _h.jumpTo(target);
    } else {
      _h.animateTo(target, duration: duration, curve: Motion.enter);
    }
  }

  /// Seçilen günde şu anki saatin yarım saat öncesine gider.
  void _jumpToDay(DateTime day) {
    final now = widget.now.toLocal();
    final target = DateTime(day.year, day.month, day.day, now.hour,
            now.minute)
        .subtract(const Duration(minutes: 30));
    _scrollTo(_x(target));
  }

  /// Klavyeyle odaklanan program görünür değilse başına kaydırır.
  void _reveal(Programme p) {
    if (!_h.hasClients) return;
    final start = _x(p.start), offset = _h.offset;
    if (start < offset || start > offset + _stripWidth - 48) {
      _h.jumpTo((start - 24).clamp(0.0, _h.position.maxScrollExtent));
    }
  }

  /// Satırların üzerinde yatay kaydırma: dokunmatik yüzeyin yatay hareketi
  /// ve Shift+tekerlek. Dikey liste bu olaylarla ilgilenmez.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_h.hasClients) return;
    final shift = HardwareKeyboard.instance.isShiftPressed &&
        event.kind == PointerDeviceKind.mouse;
    final delta = shift ? event.scrollDelta.dy : event.scrollDelta.dx;
    if (delta == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      _h.position.pointerScroll(rtl ? -delta : delta);
    });
  }

  bool _onAir(Programme p) =>
      !p.start.isAfter(widget.now) && p.stop.isAfter(widget.now);

  bool _playable(Channel channel, Programme p) =>
      canWatchFromArchive(p, widget.now, widget.archiveDays(channel));

  /// Tık: yayındaysa kanal, arşivdeyse geçmiş yayın; değilse yalnız ayrıntı.
  VoidCallback _tapAction(Channel channel, Programme p) {
    if (_onAir(p)) return () => widget.onWatch(channel);
    if (_playable(channel, p)) return () => widget.onArchive(channel, p);
    return () => _detail.value = (channel: channel, programme: p);
  }

  Future<void> _showMenu(
      Channel channel, Programme p, Offset position) async {
    final l = context.l10n;
    final onAir = _onAir(p), playable = _playable(channel, p);
    PopupMenuItem<VoidCallback> item(
            IconData icon, String label, VoidCallback action) =>
        PopupMenuItem(
          value: action,
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            contentPadding: EdgeInsets.zero,
          ),
        );
    final action = await showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        if (onAir)
          item(Icons.live_tv, l.watchLive, () => widget.onWatch(channel)),
        if (playable)
          item(
            onAir ? Icons.restart_alt : Icons.history,
            onAir ? l.watchFromStart : l.watchFromArchive,
            () => widget.onArchive(channel, p),
          ),
        item(Icons.calendar_view_day, l.schedule,
            () => widget.onSchedule(channel)),
      ],
    );
    action?.call();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        _stripWidth =
            math.max(0, constraints.maxWidth - GuideView.channelWidth);
        return Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _detail,
              builder: (context, detail, _) =>
                  _DetailPanel(detail: detail, now: widget.now),
            ),
            Container(
              height: GuideView.headerHeight,
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.symmetric(
                    horizontal: BorderSide(color: c.border)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: GuideView.channelWidth,
                    child: ListenableBuilder(
                      listenable: _h,
                      builder: (context, _) => _DayPicker(
                        start: _start,
                        end: _end,
                        now: widget.now,
                        shown: _viewCenter,
                        onSelected: _jumpToDay,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      child: ListenableBuilder(
                        listenable: _h,
                        builder: (context, _) => _TimeHeader(
                          start: _start,
                          offset: _offset,
                          width: _stripWidth,
                          now: widget.now,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Listener(
                    onPointerSignal: _onPointerSignal,
                    child: ListView.builder(
                      controller: _v,
                      itemExtent: GuideView.rowHeight,
                      itemCount: widget.channels.length,
                      itemBuilder: (context, i) => _row(widget.channels[i]),
                    ),
                  ),
                  // Şu anki zaman çizgisi.
                  ListenableBuilder(
                    listenable: _h,
                    builder: (context, _) {
                      final x = _x(widget.now) - _offset;
                      if (x < 0 || x > _stripWidth) {
                        return const SizedBox.shrink();
                      }
                      return PositionedDirectional(
                        start: GuideView.channelWidth + x - 1,
                        top: 0,
                        bottom: 0,
                        width: 2,
                        child: IgnorePointer(
                          child: ColoredBox(
                              color: c.accent.withValues(alpha: 0.8)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Yatay kaydırma çubuğu; programların altında hizalı.
            Row(
              children: [
                const SizedBox(width: GuideView.channelWidth),
                Expanded(
                  child: Scrollbar(
                    controller: _h,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _h,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: _totalWidth, height: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _row(Channel channel) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: GuideView.channelWidth,
            child: _ChannelCell(
              channel: channel,
              onTap: () => widget.onWatch(channel),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: ListenableBuilder(
                listenable: _h,
                builder: (context, _) => _strip(channel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Satırın görünen zaman aralığındaki programları. Solda kesilen programın
  /// kutusu görünen kenardan başlar; başlığı okunur kalır.
  Widget _strip(Channel channel) {
    final list = widget.epg.programmesFor(channel.tvgId);
    final offset = _offset, width = _stripWidth;
    if (list.isEmpty) {
      return _EmptyCell(label: context.l10n.guideNoProgramme);
    }
    Duration at(double x) => Duration(seconds: (x / _ppm * 60).round());
    final (first, last) = programmesBetween(
        list, _start.add(at(offset)), _start.add(at(offset + width)));
    return Stack(
      children: [
        for (var i = first; i < last; i++)
          ?_cell(channel, list[i], offset, width),
      ],
    );
  }

  Widget? _cell(Channel channel, Programme p, double offset, double width) {
    final x0 = _x(p.start) - offset, x1 = _x(p.stop) - offset;
    final start = math.max(x0, 0.0), end = math.min(x1, width);
    // Kutular arasında 2 px boşluk.
    if (end - start < 4) return null;
    return PositionedDirectional(
      key: ObjectKey(p),
      start: start,
      width: end - start - 2,
      top: 3,
      bottom: 3,
      child: _ProgrammeCell(
        programme: p,
        now: widget.now,
        onAir: _onAir(p),
        playable: _playable(channel, p),
        clipped: x0 < 0,
        onTap: _tapAction(channel, p),
        onSecondaryTapUp: (d) => _showMenu(channel, p, d.globalPosition),
        onHighlight: () => _detail.value = (channel: channel, programme: p),
        onFocus: () => _reveal(p),
      ),
    );
  }
}

/// Kanal sütunu: logo ve ad; tıklayınca kanal açılır.
class _ChannelCell extends StatelessWidget {
  const _ChannelCell({required this.channel, required this.onTap});

  final Channel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.xs),
          decoration: BoxDecoration(
            border: BorderDirectional(end: BorderSide(color: c.border)),
          ),
          child: Row(
            children: [
              ChannelLogo(url: channel.logo, name: channel.name, size: 40),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  channel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.fg,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yayın akışı olmayan kanalın satırı.
class _EmptyCell extends StatelessWidget {
  const _EmptyCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.sm),
        decoration: BoxDecoration(
          borderRadius: Radii.smAll,
          border: Border.all(color: c.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: c.fgSubtle),
        ),
      ),
    );
  }
}

/// Izgaradaki program kutusu: başlık ve saat. Yayındaki kırmızı tonlu ve
/// ilerleme çubuklu; izlenemeyen geçmiş programlar soluk.
class _ProgrammeCell extends StatefulWidget {
  const _ProgrammeCell({
    required this.programme,
    required this.now,
    required this.onAir,
    required this.playable,
    required this.clipped,
    required this.onTap,
    required this.onSecondaryTapUp,
    required this.onHighlight,
    required this.onFocus,
  });

  final Programme programme;
  final DateTime now;
  final bool onAir;

  /// Geçmiş yayından izlenebilir.
  final bool playable;

  /// Başı görünen alanın solunda kalıyor.
  final bool clipped;
  final VoidCallback onTap;
  final GestureTapUpCallback onSecondaryTapUp;

  /// Fareyle üzerine gelinince ya da odaklanınca.
  final VoidCallback onHighlight;
  final VoidCallback onFocus;

  @override
  State<_ProgrammeCell> createState() => _ProgrammeCellState();
}

class _ProgrammeCellState extends State<_ProgrammeCell> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    final p = widget.programme;
    final past = !p.stop.isAfter(widget.now);
    final dim = past && !widget.playable;
    final onAir = widget.onAir;
    final background = onAir
        ? c.accent.withValues(alpha: _hovered ? 0.26 : 0.16)
        : _hovered
            ? c.muted
            : c.surfaceRaised;
    return Semantics(
      button: true,
      label: '${p.title}, ${l.time(p.start)} – ${l.time(p.stop)}',
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) {
          setState(() => _hovered = v);
          if (v) widget.onHighlight();
        },
        onFocusChange: (v) {
          setState(() => _focused = v);
          if (v) {
            widget.onHighlight();
            widget.onFocus();
          }
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => widget.onTap()),
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onSecondaryTapUp: widget.onSecondaryTapUp,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: background,
              borderRadius: widget.clipped
                  ? const BorderRadiusDirectional.horizontal(
                          end: Radius.circular(Radii.sm))
                      .resolve(Directionality.of(context))
                  : Radii.smAll,
              border: Border.all(
                color: _focused
                    ? c.focusRing
                    : onAir
                        ? c.accent.withValues(alpha: 0.5)
                        : c.border,
                width: _focused ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: Space.xs),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.playable && !onAir) ...[
                            Icon(Icons.history,
                                size: 14, color: c.fgMuted),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              p.title,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: dim ? c.fgSubtle : c.fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l.time(p.start)} – ${l.time(p.stop)}',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: dim ? c.fgSubtle : c.fgMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onAir)
                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: 0,
                    height: 2,
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: p.progress(widget.now),
                      child: ColoredBox(color: c.accent),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Zaman ekseni: yarım saatte bir saat etiketi.
class _TimeHeader extends StatelessWidget {
  const _TimeHeader({
    required this.start,
    required this.offset,
    required this.width,
    required this.now,
  });

  final DateTime start;
  final double offset;
  final double width;
  final DateTime now;

  static const _step = 30;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l = context.l10n;
    const ppm = GuideView.pixelsPerMinute;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: c.fgMuted,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    final first = (offset / ppm / _step).floor();
    final last = ((offset + width) / ppm / _step).ceil();
    final nowX = now.difference(start).inSeconds / 60 * ppm - offset;
    return Stack(
      children: [
        for (var i = first; i <= last; i++) ...[
          PositionedDirectional(
            start: i * _step * ppm - offset,
            bottom: 0,
            width: 1,
            height: i.isEven ? 10 : 6,
            child: ColoredBox(color: c.border),
          ),
          PositionedDirectional(
            start: i * _step * ppm - offset + 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                l.time(start.add(Duration(minutes: i * _step))),
                style: style,
              ),
            ),
          ),
        ],
        if (nowX >= 0 && nowX <= width)
          PositionedDirectional(
            start: nowX - 1,
            top: 0,
            bottom: 0,
            width: 2,
            child: ColoredBox(color: c.accent),
          ),
      ],
    );
  }
}

/// Sol üst köşe: görünen günün adı; tıklayınca başka güne gidilir.
class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.start,
    required this.end,
    required this.now,
    required this.shown,
    required this.onSelected,
  });

  final DateTime start;
  final DateTime end;
  final DateTime now;

  /// Görünen alanın ortasındaki an.
  final DateTime shown;
  final ValueChanged<DateTime> onSelected;

  List<DateTime> get _days {
    final days = <DateTime>[];
    for (var d = start; d.isBefore(end); d = DateTime(d.year, d.month, d.day + 1)) {
      days.add(d);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l = context.l10n;
    final local = shown.toLocal();
    final shownDay = DateTime(local.year, local.month, local.day);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: c.border)),
      ),
      child: PopupMenuButton<DateTime>(
        tooltip: l.pickDay,
        onSelected: onSelected,
        position: PopupMenuPosition.under,
        itemBuilder: (context) => [
          for (final day in _days)
            CheckedPopupMenuItem(
              value: day,
              checked: day == shownDay,
              child: Text(l.dayLabel(day, now)),
            ),
        ],
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: Space.sm),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: IconSizes.sm, color: c.fgMuted),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  l.dayLabel(shownDay, now),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: c.fg),
                ),
              ),
              Icon(Icons.expand_more, size: IconSizes.md, color: c.fgMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Üstteki ayrıntı paneli: üzerine gelinen programın kanalı, günü, saati,
/// süresi ve açıklaması. Boşken rehberin nasıl kullanıldığını anlatır.
class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.detail, required this.now});

  final _Detail? detail;
  final DateTime now;

  static const double height = 92;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    final detail = this.detail;
    if (detail == null) {
      return Container(
        height: height,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.lg),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: IconSizes.md, color: c.fgMuted),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                l.guideHint,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }
    final (:channel, :programme) = detail;
    final p = programme;
    final onAir = !p.start.isAfter(now) && p.stop.isAfter(now);
    final meta = [
      l.upper(channel.name),
      l.dayLabel(p.start, now),
      '${l.time(p.start)} – ${l.time(p.stop)}',
      l.duration(p.stop.difference(p.start)),
    ].join(' · ');
    return Container(
      height: height,
      padding: const EdgeInsetsDirectional.fromSTEB(
          Space.lg, Space.sm, Space.lg, Space.sm),
      child: Row(
        children: [
          ChannelLogo(url: channel.logo, name: channel.name, size: 52),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: c.fgMuted),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (onAir) ...[
                      const SizedBox(width: Space.xs),
                      LiveBadge(label: l.nowBadge, compact: true),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  p.description ?? l.noDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

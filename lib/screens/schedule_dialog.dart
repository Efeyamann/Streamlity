import 'package:flutter/material.dart';

import '../models/epg.dart';
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';

/// Bir kanalın günlere ayrılmış yayın akışı. Şu anki program vurgulanır ve
/// açılışta ona kaydırılır.
///
/// Kanalın geçmiş yayını varsa [archiveDays] içindeki geçmiş ve yayındaki
/// programlar tıklanabilir; seçilen program döner.
Future<Programme?> showScheduleDialog(
  BuildContext context, {
  required String channelName,
  required List<Programme> programmes,
  int archiveDays = 0,
}) =>
    showDialog<Programme>(
      context: context,
      builder: (_) => _ScheduleDialog(
        channelName: channelName,
        programmes: programmes,
        now: DateTime.now(),
        archiveDays: archiveDays,
      ),
    );

/// Geçmiş yayından izlenebilir mi: başlamış ve arşiv süresi içinde.
bool canWatchFromArchive(Programme p, DateTime now, int archiveDays) =>
    archiveDays > 0 &&
    !p.start.isAfter(now) &&
    p.start.isAfter(now.subtract(Duration(days: archiveDays)));

class _ScheduleDialog extends StatelessWidget {
  const _ScheduleDialog({
    required this.channelName,
    required this.programmes,
    required this.now,
    required this.archiveDays,
  });

  final String channelName;
  final List<Programme> programmes;
  final DateTime now;
  final int archiveDays;

  static const _weekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static String _dayLabel(DateTime day, DateTime today) {
    final diff = day.difference(today).inDays;
    final date = '${day.day.toString().padLeft(2, '0')}.'
        '${day.month.toString().padLeft(2, '0')}';
    return switch (diff) {
      0 => 'Bugün',
      1 => 'Yarın',
      -1 => 'Dün',
      _ => '${_weekdays[day.weekday - 1]} $date',
    };
  }

  @override
  Widget build(BuildContext context) {
    final days = scheduleByDay(programmes, now, pastDays: archiveDays);
    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    final todayIndex = days.keys.toList().indexOf(today);
    final c = AppColors.of(context);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: DefaultTabController(
          length: days.length,
          initialIndex: todayIndex < 0 ? 0 : todayIndex,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Space.lg, Space.md, Space.xs, Space.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            channelName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: c.fgMuted),
                          ),
                          const SizedBox(height: 2),
                          Text('Yayın akışı',
                              style: Theme.of(context).textTheme.titleLarge),
                          if (archiveDays > 0) ...[
                            const SizedBox(height: Space.xs),
                            Row(
                              children: [
                                Icon(Icons.history,
                                    size: IconSizes.sm, color: c.accent),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Geçmiş $archiveDays gün izlenebilir, '
                                    'programa tıkla',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kapat',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              if (days.isEmpty)
                const SizedBox(
                  height: 260,
                  child: EmptyState(
                    icon: Icons.event_busy,
                    title: 'Bu kanal için program yok',
                  ),
                )
              else ...[
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    for (final day in days.keys)
                      Tab(text: _dayLabel(day, today)),
                  ],
                ),
                Flexible(
                  child: TabBarView(
                    children: [
                      for (final list in days.values)
                        _DayList(
                            programmes: list,
                            now: now,
                            archiveDays: archiveDays),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DayList extends StatefulWidget {
  const _DayList({
    required this.programmes,
    required this.now,
    required this.archiveDays,
  });

  final List<Programme> programmes;
  final DateTime now;
  final int archiveDays;

  @override
  State<_DayList> createState() => _DayListState();
}

class _DayListState extends State<_DayList> {
  static const _rowHeight = 72.0;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    // Şu anki (yoksa ilk gelecek) programa kaydır.
    final i = widget.programmes.indexWhere((p) => p.stop.isAfter(widget.now));
    _scroll = ScrollController(
        initialScrollOffset: i <= 0 ? 0 : (i - 1) * _rowHeight);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static String _time(DateTime t) {
    final local = t.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = AppColors.of(context);
    final now = widget.now;
    const tabular = [FontFeature.tabularFigures()];
    return ListView.builder(
      controller: _scroll,
      itemExtent: _rowHeight,
      itemCount: widget.programmes.length,
      itemBuilder: (context, i) {
        final p = widget.programmes[i];
        final onAir = !p.start.isAfter(now) && p.stop.isAfter(now);
        final past = !p.stop.isAfter(now);
        final playable = canWatchFromArchive(p, now, widget.archiveDays);
        final dim = past && !playable;
        final row = Container(
          decoration: BoxDecoration(
            color: onAir ? c.accent.withValues(alpha: 0.10) : null,
            border: Border(
              left: BorderSide(
                  color: onAir ? c.accent : Colors.transparent, width: 3),
              bottom: BorderSide(color: c.border),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
              Space.lg - 3, Space.sm, Space.lg, Space.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  _time(p.start),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: dim
                        ? c.fgSubtle
                        : onAir
                            ? c.accent
                            : c.fgMuted,
                    fontFeatures: tabular,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: dim ? c.fgSubtle : c.fg),
                          ),
                        ),
                        if (onAir) ...[
                          const SizedBox(width: Space.xs),
                          const LiveBadge(label: 'ŞİMDİ', compact: true),
                        ],
                      ],
                    ),
                    if (onAir)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.xs),
                        child: ClipRRect(
                          borderRadius: Radii.smAll,
                          child: LinearProgressIndicator(
                            value: p.progress(now),
                            minHeight: 3,
                            backgroundColor: c.border,
                          ),
                        ),
                      )
                    else if (p.description case final desc?)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: dim ? c.fgSubtle : c.fgMuted),
                        ),
                      ),
                  ],
                ),
              ),
              if (playable)
                Padding(
                  padding: const EdgeInsets.only(left: Space.xs),
                  child: Tooltip(
                    message: onAir ? 'Baştan izle' : 'Geçmişten izle',
                    child: Icon(
                        onAir ? Icons.restart_alt : Icons.play_circle_outline,
                        size: IconSizes.md,
                        color: c.accent),
                  ),
                ),
            ],
          ),
        );
        return playable
            ? InkWell(onTap: () => Navigator.of(context).pop(p), child: row)
            : row;
      },
    );
  }
}

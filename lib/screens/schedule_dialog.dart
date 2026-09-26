import 'package:flutter/material.dart';

import '../models/epg.dart';

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
                padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yayın akışı',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            archiveDays > 0
                                ? '$channelName · geçmiş $archiveDays gün '
                                    'izlenebilir, programa tıkla'
                                : channelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
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
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Bu kanal için program yok')),
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
    final scheme = theme.colorScheme;
    final now = widget.now;
    return ListView.builder(
      controller: _scroll,
      itemExtent: _rowHeight,
      itemCount: widget.programmes.length,
      itemBuilder: (context, i) {
        final p = widget.programmes[i];
        final onAir = !p.start.isAfter(now) && p.stop.isAfter(now);
        final past = !p.stop.isAfter(now);
        final playable =
            canWatchFromArchive(p, now, widget.archiveDays);
        final muted = past && !playable
            ? scheme.onSurface.withValues(alpha: 0.45)
            : null;
        final row = Container(
          color: onAir ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  _time(p.start),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: muted ?? (onAir ? scheme.primary : null),
                    fontFeatures: const [FontFeature.tabularFigures()],
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
                                ?.copyWith(color: muted),
                          ),
                        ),
                        if (onAir) ...[
                          const SizedBox(width: 8),
                          Text('ŞİMDİ',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700)),
                        ],
                        if (playable) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: onAir ? 'Baştan izle' : 'Geçmişten izle',
                            child: Icon(
                                onAir ? Icons.restart_alt : Icons.history,
                                size: 16,
                                color: scheme.primary),
                          ),
                        ],
                      ],
                    ),
                    if (onAir)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: LinearProgressIndicator(
                            value: p.progress(now), minHeight: 3),
                      )
                    else if (p.description case final desc?)
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: muted ?? scheme.onSurfaceVariant),
                      ),
                  ],
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

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/epg.dart';
import '../models/playlist.dart';
import '../services/watch_progress_store.dart';
import '../ui/tokens.dart';
import '../ui/widgets/common.dart';
import '../ui/widgets/poster.dart';
import '../ui/widgets/shelf.dart';

/// Ana sayfadaki hızlı geçiş kartı.
typedef HomeShortcut = ({
  IconData icon,
  String label,
  String? detail,
  VoidCallback onTap,
});

/// Listenin ana sayfası: karşılama, hızlı geçişler ve raflar (izlemeye
/// devam et, son izlenen kanallar, favori paketler).
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.listName,
    required this.shortcuts,
    required this.continueWatching,
    required this.recentChannels,
    required this.favoriteGroups,
    required this.groupCounts,
    required this.nowOn,
    required this.now,
    required this.channelsLoading,
    required this.onResume,
    required this.onPlayChannel,
    required this.onOpenGroup,
  });

  final String listName;
  final List<HomeShortcut> shortcuts;
  final List<WatchEntry> continueWatching;
  final List<Channel> recentChannels;
  final List<String> favoriteGroups;
  final Map<String, int> groupCounts;
  final Programme? Function(Channel channel) nowOn;
  final DateTime now;

  /// Kanal listesi henüz yüklenmedi; kanal rafları iskelet gösterir.
  final bool channelsLoading;
  final ValueChanged<WatchEntry> onResume;
  final ValueChanged<Channel> onPlayChannel;
  final ValueChanged<String> onOpenGroup;

  static String greeting(AppLocalizations l, DateTime now) =>
      switch (now.hour) {
        >= 5 && < 12 => l.greetingMorning,
        >= 12 && < 18 => l.greetingDay,
        >= 18 && < 23 => l.greetingEvening,
        _ => l.greetingNight,
      };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final l = context.l10n;
    final empty = continueWatching.isEmpty &&
        recentChannels.isEmpty &&
        favoriteGroups.isEmpty &&
        !channelsLoading;
    return ListView(
      padding: const EdgeInsets.only(top: Space.lg, bottom: Space.xxl),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting(l, now), style: theme.textTheme.displaySmall),
              const SizedBox(height: Space.xxs),
              Text(
                empty ? l.homeIntroEmpty(listName) : l.homeIntro,
                style: theme.textTheme.bodyLarge?.copyWith(color: c.fgMuted),
              ),
              const SizedBox(height: Space.lg),
              Wrap(
                spacing: Space.md,
                runSpacing: Space.md,
                children: [
                  for (final s in shortcuts) _ShortcutCard(shortcut: s),
                ],
              ),
            ],
          ),
        ),
        if (continueWatching.isNotEmpty) ...[
          const SizedBox(height: Space.xl),
          Shelf(
            title: l.continueWatching,
            count: continueWatching.length,
            itemCount: continueWatching.length,
            itemWidth: 160,
            height: 300,
            itemBuilder: (context, i) {
              final e = continueWatching[i];
              final meta = e.meta!;
              final left = e.progress.duration - e.progress.position;
              return PosterCard(
                title: meta.title,
                poster: meta.poster,
                subtitle: watchSubtitle(l, meta) ??
                    (left > Duration.zero ? l.minutesLeft(left.inMinutes) : null),
                progress: e.progress.fraction,
                fallbackIcon: meta.isEpisode
                    ? Icons.video_library_outlined
                    : Icons.movie_outlined,
                onTap: () => onResume(e),
              );
            },
          ),
        ],
        if (channelsLoading || recentChannels.isNotEmpty) ...[
          const SizedBox(height: Space.xl),
          Shelf(
            title: l.recentChannels,
            count: channelsLoading ? null : recentChannels.length,
            itemCount: channelsLoading ? 5 : recentChannels.length,
            itemWidth: ChannelCard.width,
            height: ChannelCard.height,
            itemBuilder: (context, i) {
              if (channelsLoading) {
                return const Skeleton(radius: Radii.lgAll);
              }
              final channel = recentChannels[i];
              final programme = nowOn(channel);
              return ChannelCard(
                name: channel.name,
                logo: channel.logo,
                programme: programme?.title,
                progress: programme?.progress(now),
                caption: channel.group == null ? null : l.group(channel.group!),
                onTap: () => onPlayChannel(channel),
              );
            },
          ),
        ],
        if (favoriteGroups.isNotEmpty) ...[
          const SizedBox(height: Space.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.favoritePackages, style: theme.textTheme.titleMedium),
                const SizedBox(height: Space.sm),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    for (final g in favoriteGroups)
                      _GroupChip(
                        label: l.group(g),
                        count: groupCounts[g],
                        onTap: () => onOpenGroup(g),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ShortcutCard extends StatefulWidget {
  const _ShortcutCard({required this.shortcut});

  final HomeShortcut shortcut;

  @override
  State<_ShortcutCard> createState() => _ShortcutCardState();
}

class _ShortcutCardState extends State<_ShortcutCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final s = widget.shortcut;
    final lit = _hovered || _focused;
    return Semantics(
      button: true,
      label: s.label,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent:
              CallbackAction<ActivateIntent>(onInvoke: (_) => s.onTap()),
        },
        child: GestureDetector(
          onTap: s.onTap,
          child: AnimatedContainer(
            duration: motion.fast,
            width: 200,
            height: 92,
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              borderRadius: Radii.lgAll,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: lit
                    ? [c.accent.withValues(alpha: 0.28), c.surfaceRaised]
                    : [c.surfaceRaised, c.surface],
              ),
              border: Border.all(
                color: _focused
                    ? c.focusRing
                    : lit
                        ? c.accent.withValues(alpha: 0.6)
                        : c.border,
                width: _focused ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(s.icon, size: 28, color: lit ? c.accent : c.fg),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.label, style: theme.textTheme.titleSmall),
                      if (s.detail case final detail?)
                        Text(detail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall),
                    ],
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

class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.label, required this.onTap, this.count});

  final String label;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
          borderRadius: Radii.mdAll, side: BorderSide(color: c.border)),
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.mdAll,
        hoverColor: c.surfaceRaised,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Space.md, vertical: Space.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: IconSizes.md, color: c.accent),
              const SizedBox(width: Space.xs),
              Text(label, style: theme.textTheme.labelLarge),
              if (count != null) ...[
                const SizedBox(width: Space.xs),
                Text(context.l10n.count(count!),
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: c.fgMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'channel_tile.dart';
import 'common.dart';

/// Başlıklı yatay raf. Taşarsa başlığın yanında kaydırma okları çıkar.
class Shelf extends StatefulWidget {
  const Shelf({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemWidth,
    required this.height,
    this.count,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: Space.xl),
  });

  final String title;
  final int? count;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemWidth;
  final double height;

  /// Başlığın sağında (ör. "Tümünü gör").
  final Widget? action;
  final EdgeInsets padding;

  @override
  State<Shelf> createState() => _ShelfState();
}

/// Kartların hover'daki büyümesi ve gölgesi için dikey pay.
const double _hoverRoom = Space.sm;

class _ShelfState extends State<Shelf> {
  final _scroll = ScrollController();
  bool _canBack = false;
  bool _canForward = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(Shelf old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted || !_scroll.hasClients) return;
    final p = _scroll.position;
    final back = p.pixels > 1, forward = p.pixels < p.maxScrollExtent - 1;
    if (back != _canBack || forward != _canForward) {
      setState(() {
        _canBack = back;
        _canForward = forward;
      });
    }
  }

  void _page(int direction) {
    final p = _scroll.position;
    final target = (p.pixels + direction * p.viewportDimension * 0.85)
        .clamp(0.0, p.maxScrollExtent);
    final motion = Motion.of(context);
    if (motion.slow == Duration.zero) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(target, duration: motion.slow, curve: Motion.enter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: widget.padding.copyWith(bottom: Space.xxs),
          child: Row(
            children: [
              Text(widget.title, style: theme.textTheme.titleMedium),
              if (widget.count case final count?) ...[
                const SizedBox(width: Space.xs),
                Text(formatCount(count),
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: c.fgMuted)),
              ],
              const Spacer(),
              ?widget.action,
              if (_canBack || _canForward) ...[
                const SizedBox(width: Space.xs),
                IconButton(
                  tooltip: 'Geri kaydır',
                  visualDensity: VisualDensity.compact,
                  onPressed: _canBack ? () => _page(-1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'İleri kaydır',
                  visualDensity: VisualDensity.compact,
                  onPressed: _canForward ? () => _page(1) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          // Hover'da büyüyen kartlar kesilmesin diye alt ve üstte pay.
          height: widget.height + 2 * _hoverRoom,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              _update();
              return false;
            },
            child: ListView.separated(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: widget.padding
                  .copyWith(top: _hoverRoom, bottom: _hoverRoom),
              itemCount: widget.itemCount,
              separatorBuilder: (_, _) => const SizedBox(width: Space.md),
              itemBuilder: (context, i) => SizedBox(
                width: widget.itemWidth,
                child: widget.itemBuilder(context, i),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Ana sayfa ve aramadaki kanal kartı: logo, ad, şu anki program.
class ChannelCard extends StatefulWidget {
  const ChannelCard({
    super.key,
    required this.name,
    required this.logo,
    required this.onTap,
    this.programme,
    this.progress,
    this.caption,
  });

  static const double width = 248;
  static const double height = 112;

  final String name;
  final String? logo;
  final String? programme;
  final double? progress;

  /// Program yoksa gösterilen alt satır (ör. kategori adı).
  final String? caption;
  final VoidCallback onTap;

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final lit = _hovered || _focused;
    final progress = widget.progress;
    return Semantics(
      button: true,
      label: widget.name,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent:
              CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap()),
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: motion.fast,
            padding: const EdgeInsets.all(Space.sm),
            decoration: BoxDecoration(
              color: lit ? c.surfaceRaised : c.surface,
              borderRadius: Radii.lgAll,
              border: Border.all(
                color: _focused
                    ? c.focusRing
                    : lit
                        ? const Color(0x33FFFFFF)
                        : c.border,
                width: _focused ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ChannelLogo(url: widget.logo, name: widget.name, size: 40),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        widget.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: motion.fast,
                      opacity: lit ? 1 : 0,
                      child: Icon(Icons.play_circle_fill_rounded,
                          color: c.accent, size: 28),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.programme ?? widget.caption ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                if (progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: Radii.smAll,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: c.border,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

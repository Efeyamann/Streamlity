import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Ağdan poster; yüklenirken gri zemin, açılmazsa ikonlu yer tutucu.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.movie_outlined,
    this.cacheWidth = 340,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final IconData fallbackIcon;

  /// Büyük katalogda bellek için küçük çöz.
  final int? cacheWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fallback = ColoredBox(
      color: c.surfaceRaised,
      child: Center(child: Icon(fallbackIcon, size: 36, color: c.fgSubtle)),
    );
    final url = this.url;
    if (url == null) return fallback;
    return Image.network(
      url,
      fit: fit,
      cacheWidth: cacheWidth,
      // Yavaş ya da yanıt vermeyen sunucuda kart boş görünmesin.
      frameBuilder: (_, child, frame, sync) => frame == null && !sync
          ? ColoredBox(color: c.surfaceRaised)
          : child,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// Poster kartı: hover'da hafif büyür ve oynat simgesi belirir; puan rozeti
/// ve izleme ilerlemesi posterin üstünde. Büyüme yerleşimi kaydırmaz.
class PosterCard extends StatefulWidget {
  const PosterCard({
    super.key,
    required this.title,
    required this.poster,
    required this.onTap,
    this.subtitle,
    this.rating,
    this.progress,
    this.fallbackIcon = Icons.movie_outlined,
  });

  final String title;
  final String? poster;
  final String? subtitle;
  final double? rating;

  /// 0–1; null ise çubuk yok.
  final double? progress;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final lit = _hovered || _focused;
    final rating = widget.rating;
    final progress = widget.progress;
    return Semantics(
      button: true,
      label: widget.title,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AnimatedScale(
                  scale: lit ? 1.04 : 1,
                  duration: motion.base,
                  curve: Motion.enter,
                  child: AnimatedContainer(
                    duration: motion.base,
                    decoration: BoxDecoration(
                      borderRadius: Radii.mdAll,
                      border: Border.all(
                        color: _focused
                            ? c.focusRing
                            : lit
                                ? const Color(0x55FFFFFF)
                                : c.border,
                        width: _focused ? 2 : 1,
                      ),
                      boxShadow: lit
                          ? const [
                              BoxShadow(
                                color: Color(0x99000000),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ]
                          : const [],
                    ),
                    child: ClipRRect(
                      borderRadius: Radii.mdAll,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PosterImage(
                              url: widget.poster,
                              fallbackIcon: widget.fallbackIcon),
                          // Hover'da alttan koyulaşma ve oynat simgesi.
                          AnimatedOpacity(
                            duration: motion.base,
                            opacity: lit ? 1 : 0,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00000000),
                                    Color(0xAA000000),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: c.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.play_arrow_rounded,
                                      size: 30, color: c.onAccent),
                                ),
                              ),
                            ),
                          ),
                          if (rating != null && rating > 0)
                            PositionedDirectional(
                              top: 6,
                              start: 6,
                              child: RatingBadge(rating: rating),
                            ),
                          if (progress != null)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                                backgroundColor: const Color(0x66000000),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Space.xs),
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: lit ? c.fg : c.fg.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              if (widget.subtitle case final subtitle?)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "★ 8.1" rozeti; görsel üstünde okunsun diye koyu zeminli.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: c.scrim, borderRadius: Radii.smAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 12, color: c.warning),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: c.fg, letterSpacing: 0, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yıl, süre, tür gibi küçük bilgi etiketi.
class MetaChip extends StatelessWidget {
  const MetaChip(this.label, {super.key, this.icon, this.iconColor});

  final String label;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: Radii.smAll,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon case final icon?) ...[
              Icon(icon, size: 14, color: iconColor ?? c.fgMuted),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: c.fg)),
          ],
        ),
      ),
    );
  }
}

/// Sayfanın arkasında bulanık, alta doğru zemine karışan görsel.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key, required this.url, this.blur = 28});

  final String? url;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final url = this.url;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Opacity(
              opacity: 0.55,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                cacheWidth: 480,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.bg.withValues(alpha: 0.35), c.bg],
              stops: const [0, 0.85],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: [c.bg.withValues(alpha: 0.7), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

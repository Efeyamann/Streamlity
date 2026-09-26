import 'package:flutter/material.dart';

import '../tokens.dart';
import 'common.dart';

/// Kanal logosu: koyu, yuvarlatılmış kutuda. Logo yoksa ya da açılmazsa
/// kanal adının baş harfleri.
class ChannelLogo extends StatelessWidget {
  const ChannelLogo({
    super.key,
    required this.url,
    required this.name,
    this.size = 44,
  });

  final String? url;
  final String name;
  final double size;

  static String initials(String name) {
    // "TR: ATV HD" -> "AT"; ön ekleri ve kalite etiketlerini atla.
    final words = name
        .replaceAll(RegExp(r'^[^:|]{1,6}[:|]\s*'), '')
        .split(RegExp(r'[\s\-_:|]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.characters.take(2).toString().toUpperCase();
    }
    return (words[0].characters.first + words[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fallback = Center(
      child: Text(
        initials(name),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: c.fgMuted,
              fontSize: size * 0.3,
            ),
      ),
    );
    final url = this.url;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: Radii.mdAll,
        border: Border.all(color: c.border),
      ),
      child: url == null
          ? fallback
          : Image.network(
              url,
              fit: BoxFit.contain,
              cacheWidth: 96,
              frameBuilder: (_, child, frame, sync) =>
                  frame == null && !sync ? const SizedBox.shrink() : child,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// Kanal satırı: logo, ad, şu anki program ve ilerlemesi. Oynayan kanalda
/// CANLI rozeti; [action] yalnız hover'da görünür.
class ChannelTile extends StatefulWidget {
  const ChannelTile({
    super.key,
    required this.name,
    required this.logo,
    required this.onTap,
    this.programme,
    this.progress,
    this.playing = false,
    this.selected = false,
    this.action,
    this.onSecondaryTapUp,
  });

  static const double height = 68;

  final String name;
  final String? logo;
  final String? programme;
  final double? progress;
  final bool playing;
  final bool selected;
  final Widget? action;
  final VoidCallback onTap;
  final GestureTapUpCallback? onSecondaryTapUp;

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final selected = widget.selected;
    final progress = widget.progress;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onSecondaryTapUp: widget.onSecondaryTapUp,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: Radii.mdAll,
              hoverColor: Colors.transparent,
              child: AnimatedContainer(
                duration: motion.fast,
                padding: const EdgeInsets.symmetric(horizontal: Space.xs),
                decoration: BoxDecoration(
                  color: selected
                      ? c.muted
                      : _hovered
                          ? c.surfaceRaised
                          : Colors.transparent,
                  borderRadius: Radii.mdAll,
                  border: Border.all(
                    color: selected
                        ? c.accent.withValues(alpha: 0.55)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    ChannelLogo(url: widget.logo, name: widget.name),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: c.fg,
                                  ),
                                ),
                              ),
                              if (widget.playing) ...[
                                const SizedBox(width: 6),
                                const LiveBadge(compact: true),
                              ],
                            ],
                          ),
                          if (widget.programme case final programme?) ...[
                            const SizedBox(height: 2),
                            Text(
                              programme,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                          if (progress != null) ...[
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: Radii.smAll,
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 2,
                                color: selected || widget.playing
                                    ? c.accent
                                    : c.fgMuted,
                                backgroundColor: c.border,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.action case final action?)
                      AnimatedOpacity(
                        duration: motion.fast,
                        opacity: _hovered ? 1 : 0,
                        child: IgnorePointer(ignoring: !_hovered, child: action),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

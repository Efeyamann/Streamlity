import 'package:flutter/material.dart';

import '../tokens.dart';
import 'logo_mark.dart';

/// Sol menüdeki bir öğe.
class RailItem<T> {
  const RailItem({
    required this.value,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.tooltip,
  });

  final T value;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Kısayol gibi ek bilgi; yoksa [label].
  final String? tooltip;
}

/// Dar, ikonlu sol menü: üstte logo, ortada bölümler, altta [footer].
class AppRail<T> extends StatelessWidget {
  const AppRail({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.footer = const [],
  });

  static const double width = 76;

  final List<RailItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Menünün altına yaslanan öğeler (ör. listelere dönüş).
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Tab önce menüyü baştan sona gezsin, sonra içeriğe geçsin.
    return FocusTraversalGroup(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(right: BorderSide(color: c.border)),
        ),
        child: Column(
          children: [
            const SizedBox(height: Space.md),
            const LogoMark(size: 36),
            const SizedBox(height: Space.lg),
            for (final item in items)
              RailButton(
                icon: item.icon,
                selectedIcon: item.selectedIcon,
                label: item.label,
                tooltip: item.tooltip,
                selected: item.value == selected,
                onTap: () => onSelected(item.value),
              ),
            const Spacer(),
            ...footer,
            const SizedBox(height: Space.sm),
          ],
        ),
      ),
    );
  }
}

/// Menü düğmesi: seçiliyken dolu ikon, beyaz yazı ve soldaki kırmızı çizgi.
class RailButton extends StatefulWidget {
  const RailButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selectedIcon,
    this.selected = false,
    this.tooltip,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<RailButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final motion = Motion.of(context);
    final selected = widget.selected;
    final color = selected || _hovered ? c.fg : c.fgMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: widget.label,
      excludeSemantics: true,
      child: Tooltip(
        message: widget.tooltip ?? widget.label,
        preferBelow: false,
        verticalOffset: 0,
        margin: const EdgeInsets.only(left: AppRail.width),
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowHoverHighlight: (v) => setState(() => _hovered = v),
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) => widget.onTap()),
          },
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 64,
              child: Stack(
                children: [
                  // Seçili bölüm göstergesi.
                  AnimatedPositioned(
                    duration: motion.base,
                    curve: Motion.enter,
                    left: 0,
                    top: selected ? 16 : 32,
                    bottom: selected ? 16 : 32,
                    width: 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected ? c.accent : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(3)),
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedContainer(
                      duration: motion.fast,
                      curve: Motion.enter,
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _hovered && !selected
                            ? c.surfaceRaised
                            : Colors.transparent,
                        borderRadius: Radii.mdAll,
                        border: _focused
                            ? Border.all(color: c.focusRing, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected
                                ? widget.selectedIcon ?? widget.icon
                                : widget.icon,
                            size: IconSizes.lg,
                            color: selected ? c.accent : color,
                          ),
                          const SizedBox(height: Space.xxs),
                          Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

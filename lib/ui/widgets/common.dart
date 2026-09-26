import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../tokens.dart';

/// Liste bölümlerinin küçük, büyük harfli başlığı.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.label, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, 6),
    this.trailing,
  });

  final String label;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.upper(label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: c.fgMuted),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Arama kutusu: büyüteç, yazınca temizleme düğmesi.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.autofocus = false,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, size: IconSizes.md),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: context.l10n.clear,
                  iconSize: IconSizes.sm,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                ),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

/// Kırmızı nokta ve "CANLI" etiketi.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.label, this.compact = false});

  /// Varsayılan "CANLI".
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: c.live, borderRadius: Radii.smAll),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 6, vertical: compact ? 1 : 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: c.onAccent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label ?? context.l10n.liveBadge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c.onAccent,
                    fontSize: compact ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Klavye tuşu görünümü (kısayol ipuçları için).
class Kbd extends StatelessWidget {
  const Kbd(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: Radii.smAll,
        border: Border(
          top: BorderSide(color: c.border),
          left: BorderSide(color: c.border),
          right: BorderSide(color: c.border),
          bottom: const BorderSide(color: Color(0x33FFFFFF), width: 2),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: c.fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Boş ya da hatalı durum: ikon, başlık, açıklama ve eylemler.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actions = const [],
    this.footer,
    this.tone,
  });

  final IconData icon;
  final String title;
  final String? message;
  final List<Widget> actions;
  final Widget? footer;

  /// İkon halkasının rengi; hata için [AppColors.danger].
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final tone = this.tone ?? c.fgMuted;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tone.withValues(alpha: 0.12),
                  border: Border.all(color: tone.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, size: 32, color: tone),
              ),
              const SizedBox(height: Space.md),
              Text(title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
              if (message case final message?) ...[
                const SizedBox(height: 6),
                Text(message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: c.fgMuted)),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: Space.lg),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  alignment: WrapAlignment.center,
                  children: actions,
                ),
              ],
              if (footer case final footer?) ...[
                const SizedBox(height: Space.xl),
                footer,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Yüklenen içeriğin yerini tutan, yavaşça nabız atan blok.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.radius = Radii.smAll,
  });

  final double? width;
  final double? height;
  final BorderRadius radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Animasyonlar kapalıysa sabit dur.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(c.muted, c.surfaceRaised,
                Curves.easeInOut.transform(_controller.value)),
            borderRadius: widget.radius,
          ),
        ),
      ),
    );
  }
}

/// Seçilebilir liste satırı: hover zemini, seçiliyken solda kırmızı çizgi.
/// [trailing] yalnız hover'da ya da [showTrailing] ise görünür.
class NavRow extends StatefulWidget {
  const NavRow({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.leading,
    this.count,
    this.trailing,
    this.showTrailing = false,
    this.height = 40,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? leading;
  final int? count;
  final Widget? trailing;
  final bool showTrailing;
  final double height;

  @override
  State<NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<NavRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final selected = widget.selected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: Radii.mdAll,
            hoverColor: Colors.transparent,
            child: AnimatedContainer(
              duration: motion.fast,
              height: widget.height,
              padding: const EdgeInsetsDirectional.only(
                  start: Space.sm, end: Space.xxs),
              decoration: BoxDecoration(
                color: selected
                    ? c.muted
                    : _hovered
                        ? c.surfaceRaised
                        : Colors.transparent,
                borderRadius: Radii.mdAll,
                border: selected
                    ? BorderDirectional(start: BorderSide(color: c.accent, width: 3))
                    : null,
              ),
              child: Row(
                children: [
                  if (widget.leading case final icon?) ...[
                    Icon(icon,
                        size: IconSizes.md,
                        color: selected ? c.fg : c.fgMuted),
                    const SizedBox(width: Space.sm),
                  ],
                  Expanded(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selected || _hovered ? c.fg : c.fgMuted,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (widget.count case final count?)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        context.l10n.count(count),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: c.fgMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  if (widget.trailing case final trailing?)
                    AnimatedOpacity(
                      duration: motion.fast,
                      opacity: widget.showTrailing || _hovered || selected
                          ? 1
                          : 0,
                      child: trailing,
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

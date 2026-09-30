import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// Adjustable column boundary with pointer and keyboard controls.
class PanelDivider extends StatefulWidget {
  const PanelDivider({super.key, required this.label, required this.onResize,
    required this.onResizeEnd, required this.onReset});

  final String label;
  final ValueChanged<double> onResize;
  final VoidCallback onResizeEnd;
  final VoidCallback onReset;

  @override
  State<PanelDivider> createState() => _PanelDividerState();
}

class _PanelDividerState extends State<PanelDivider> {
  bool _hover = false;
  bool _focused = false;
  bool _dragging = false;

  void _step(double delta) {
    widget.onResize(delta);
    widget.onResizeEnd();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final active = _hover || _focused || _dragging;
    return Semantics(
      label: widget.label,
      onIncrease: () => _step(24),
      onDecrease: () => _step(-24),
      child: Focus(
        onFocusChange: (value) => setState(() => _focused = value),
        onKeyEvent: (_, event) {
          if (event is KeyUpEvent) return KeyEventResult.ignored;
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowLeft ||
              key == LogicalKeyboardKey.arrowRight) {
            _step(key == LogicalKeyboardKey.arrowLeft ? -24 : 24);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.home) {
            widget.onReset();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: Tooltip(
            message: widget.label,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: widget.onReset,
              onHorizontalDragStart: (_) => setState(() => _dragging = true),
              onHorizontalDragUpdate: (event) => widget.onResize(event.delta.dx),
              onHorizontalDragEnd: (_) {
                setState(() => _dragging = false);
                widget.onResizeEnd();
              },
              onHorizontalDragCancel: () {
                setState(() => _dragging = false);
                widget.onResizeEnd();
              },
              child: SizedBox(
                width: 10,
                child: Stack(alignment: Alignment.center, children: [
                  Positioned.fill(child: ColoredBox(
                    color: active ? c.surfaceRaised : c.bg)),
                  Container(width: active ? 2 : 1,
                    color: active ? c.accent : c.border),
                  Container(width: 4, height: 32,
                    decoration: BoxDecoration(color: active ? c.accent : c.fgSubtle,
                      borderRadius: BorderRadius.circular(2))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

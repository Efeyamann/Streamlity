import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Streamlity işareti: kırmızı yuvarlatılmış kare içinde oynat üçgeni.
/// Uygulama ikonu da aynı çizimden üretilir.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Streamlity',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: LogoPainter(AppColors.of(context).accent),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  const LogoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & Size.square(s);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.lerp(color, Colors.white, 0.18)!, color,
        Color.lerp(color, Colors.black, 0.25)!],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(s * 0.28)),
      Paint()..shader = gradient.createShader(rect),
    );
    // Görsel olarak ortalanmış, köşeleri yumuşak oynat üçgeni.
    final cx = s * 0.54, cy = s / 2, r = s * 0.26;
    final path = Path();
    for (var i = 0; i < 3; i++) {
      final a = i * 2 * math.pi / 3;
      final p = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.06
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(LogoPainter old) => old.color != color;
}

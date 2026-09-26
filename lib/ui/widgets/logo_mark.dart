import 'package:flutter/material.dart';

/// Streamlity işareti: altı yüzlü kristal prizma biçiminde oynat üçgeni.
/// Uygulama ikonları da aynı çizimden üretilir (`tool/generate_icons_test.dart`),
/// SVG kopyaları `assets/branding/` altındadır.
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
        painter: const LogoPainter(),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  /// [tile] true ise işaret koyu, yuvarlatılmış bir karonun içine çizilir
  /// (macOS uygulama ikonu).
  const LogoPainter({this.tile = false});

  final bool tile;

  static const tileColor = Color(0xFF0C0C0D);
  static const tileBorder = Color(0x1FFFFFFF);

  // Köşeler ve kenar ortaları; 1x1 kutuda, optik olarak ortalanmış.
  static const _a = Offset(0.25, 0.16);
  static const _b = Offset(0.84, 0.50);
  static const _c = Offset(0.25, 0.84);
  static const _g = Offset(0.45, 0.50);
  static const _ab = Offset(0.545, 0.33);
  static const _bc = Offset(0.545, 0.67);
  static const _ca = Offset(0.25, 0.50);

  /// Saat yönünde yüzler; ışık sol üstten gelir.
  static const _facets = [
    (_a, _ab, Color(0xFFFDA4AF)),
    (_ab, _b, Color(0xFFFB7185)),
    (_b, _bc, Color(0xFFE11D48)),
    (_bc, _c, Color(0xFFBE123C)),
    (_c, _ca, Color(0xFF881337)),
    (_ca, _a, Color(0xFF9F1239)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    if (tile) {
      final rrect = RRect.fromRectAndRadius(
          Offset.zero & Size.square(s), Radius.circular(s * 0.225));
      canvas.drawRRect(rrect, Paint()..color = tileColor);
      canvas.drawRRect(
        rrect.deflate(s * 0.003),
        Paint()
          ..color = tileBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.006,
      );
      const inset = 0.07;
      canvas.translate(s * inset, s * inset);
      _paintMark(canvas, s * (1 - 2 * inset));
    } else {
      _paintMark(canvas, s);
    }
    canvas.restore();
  }

  void _paintMark(Canvas canvas, double s) {
    Offset p(Offset o) => o * s;
    canvas.saveLayer(Offset.zero & Size.square(s), Paint());
    for (final (from, to, color) in _facets) {
      canvas.drawPath(
        Path()
          ..moveTo(p(_g).dx, p(_g).dy)
          ..lineTo(p(from).dx, p(from).dy)
          ..lineTo(p(to).dx, p(to).dy)
          ..close(),
        Paint()
          ..color = color
          ..isAntiAlias = true,
      );
    }
    // Yüzler arasındaki boşluklar saydam; küçük boyutta da seçilsin diye
    // en az ~1 piksel.
    final gap = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = s * 0.022 > 1 ? s * 0.022 : (s * 0.05).clamp(0, 1)
      ..style = PaintingStyle.stroke;
    for (final o in [_a, _ab, _b, _bc, _c, _ca]) {
      canvas.drawLine(p(_g), p(o), gap);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter old) => old.tile != tile;
}

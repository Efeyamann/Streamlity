// Uygulama ikonlarını LogoPainter'dan üretir. `flutter test` bu klasörü
// çalıştırmaz; logo değişince elle çalıştır:
//   flutter test tool/generate_icons_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/ui/widgets/logo_mark.dart';

Future<Uint8List> _render(int px, {required bool tile, double margin = 0}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.translate(px * margin, px * margin);
  LogoPainter(tile: tile).paint(canvas, Size.square(px * (1 - 2 * margin)));
  final image = await recorder.endRecording().toImage(px, px);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

/// PNG girdili ICO (Windows Vista ve sonrası).
Uint8List _ico(Map<int, Uint8List> pngs) {
  final header = BytesBuilder();
  final body = BytesBuilder();
  var offset = 6 + 16 * pngs.length;
  final h = ByteData(6)
    ..setUint16(2, 1, Endian.little)
    ..setUint16(4, pngs.length, Endian.little);
  header.add(h.buffer.asUint8List());
  for (final MapEntry(key: px, value: png) in pngs.entries) {
    final e = ByteData(16)
      ..setUint8(0, px >= 256 ? 0 : px)
      ..setUint8(1, px >= 256 ? 0 : px)
      ..setUint16(4, 1, Endian.little)
      ..setUint16(6, 32, Endian.little)
      ..setUint32(8, png.length, Endian.little)
      ..setUint32(12, offset, Endian.little);
    header.add(e.buffer.asUint8List());
    body.add(png);
    offset += png.length;
  }
  return (header..add(body.takeBytes())).takeBytes();
}

void main() {
  testWidgets('uygulama ikonlarını üret', (tester) async {
    await tester.runAsync(() async {
      // Windows: saydam zeminde yalnız işaret.
      final win = <int, Uint8List>{
        for (final px in [16, 20, 24, 32, 40, 48, 64, 256])
          px: await _render(px, tile: false, margin: px <= 32 ? 0 : 0.02),
      };
      File('windows/runner/resources/app_icon.ico').writeAsBytesSync(_ico(win));

      // macOS: Apple ızgarasına göre kenar boşluklu koyu karo.
      const dir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
      for (final px in [16, 32, 64, 128, 256, 512, 1024]) {
        File('$dir/app_icon_$px.png')
            .writeAsBytesSync(await _render(px, tile: true, margin: 0.098));
      }

      // Önizleme ve belgeler için büyük PNG'ler.
      Directory('assets/branding').createSync(recursive: true);
      File('assets/branding/streamlity_mark_1024.png')
          .writeAsBytesSync(await _render(1024, tile: false));
      File('assets/branding/streamlity_icon_1024.png')
          .writeAsBytesSync(await _render(1024, tile: true));
    });
  });
}

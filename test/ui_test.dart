import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/ui/tokens.dart';
import 'package:streamlity/ui/widgets/channel_tile.dart';
import 'package:streamlity/ui/widgets/common.dart';

void main() {
  test('logosuz kanalda baş harfler ön eki atlar', () {
    expect(ChannelLogo.initials('TR: ATV HD'), 'AH');
    expect(ChannelLogo.initials('UK| BBC One'), 'BO');
    expect(ChannelLogo.initials('Eurosport'), 'EU');
    expect(ChannelLogo.initials(''), '?');
  });

  testWidgets('animasyonlar kapalıysa geçiş süreleri sıfır', (tester) async {
    late Motion off, on;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Builder(builder: (context) {
        off = Motion.of(context);
        return const SizedBox();
      }),
    ));
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: Builder(builder: (context) {
        on = Motion.of(context);
        return const SizedBox();
      }),
    ));
    expect(off.base, Duration.zero);
    expect(on.base, const Duration(milliseconds: 200));
  });

  test('görünen satır için kaydırma yok, görünmeyen ortalanır', () {
    double? reveal(double start, {double offset = 0}) => revealOffset(
        start: start, extent: 50, viewport: 500, offset: offset, max: 5000);
    // Ekranda: kaydırma yok.
    expect(reveal(100), isNull);
    expect(reveal(450), isNull);
    // Altta kalan satır ortaya gelir.
    expect(reveal(2000), 2000 - 225);
    // Üstte kalan satır da ortaya gelir; baştaki satır 0'ın altına inmez.
    expect(reveal(100, offset: 1000), 0);
    expect(reveal(800, offset: 1000), 800 - 225);
    // Sondaki satır en fazla kaydırma sınırına kadar.
    expect(reveal(5400), 5000);
  });
}

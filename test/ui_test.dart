import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/ui/tokens.dart';
import 'package:streamlity/ui/widgets/channel_tile.dart';
import 'package:streamlity/ui/widgets/common.dart';

void main() {
  test('sayılar binlik ayraçla yazılır', () {
    expect(formatCount(7), '7');
    expect(formatCount(999), '999');
    expect(formatCount(1000), '1.000');
    expect(formatCount(56488), '56.488');
    expect(formatCount(1234567), '1.234.567');
  });

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
}

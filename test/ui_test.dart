import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/ui/tokens.dart';
import 'package:streamlity/ui/widgets/channel_tile.dart';

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
}

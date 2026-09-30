import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamlity/ui/widgets/panel_divider.dart';

void main() {
  testWidgets('column can grow, shrink, reset and resize with keyboard', (tester) async {
    double width = 208;
    int saved = 0;
    await tester.pumpWidget(MaterialApp(home: StatefulBuilder(
      builder: (context, setState) => Scaffold(body: Row(children: [
        SizedBox(width: width),
        PanelDivider(label: 'Resize column',
          onResize: (delta) => setState(() => width += delta),
          onResizeEnd: () => saved++,
          onReset: () => setState(() => width = 208)),
        const Expanded(child: SizedBox()),
      ])),
    )));
    final divider = find.byType(PanelDivider);
    await tester.drag(divider, const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(width, greaterThan(208));
    final grown = width;
    await tester.drag(divider, const Offset(-60, 0));
    await tester.pumpAndSettle();
    expect(width, lessThan(grown));
    expect(saved, 2);
    final focus = tester.widget<Focus>(find.descendant(
      of: divider, matching: find.byType(Focus)).first);
    final element = tester.element(find.descendant(
      of: divider, matching: find.byType(GestureDetector)).first);
    Focus.of(element).requestFocus();
    await tester.pump();
    final beforeKey = width;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(width, greaterThan(beforeKey));
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(width, 208);
    expect(focus.onKeyEvent, isNotNull);
  });
}

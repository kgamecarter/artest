import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artest/hud_overlay.dart';
import 'package:ditredi/ditredi.dart';

// We mock the Ditredi widget or just test the HudOverlay visibility logic

void main() {
  testWidgets('HudOverlay is hidden when isVisible is false', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HudOverlay(isVisible: false),
      ),
    ));

    // Should find SizedBox.shrink, which effectively has no size, but let's check for DiTreDi
    // DiTreDi should NOT be in the tree if hidden
    expect(find.byType(DiTreDi), findsNothing);
  });

  testWidgets('HudOverlay shows DiTreDi when isVisible is true', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HudOverlay(isVisible: true),
      ),
    ));

    // DiTreDi should be present
    expect(find.byType(DiTreDi), findsOneWidget);
  });
}

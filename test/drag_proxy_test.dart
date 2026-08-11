import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/theme/app_metrics.dart';
import 'package:workout_log/presentation/common/drag_proxy.dart';

/// The framework's own proxy is a square canvas slab that covers the item's
/// rounded corners and the gap under it. These lock in the replacement.
void main() {
  /// Rows are 60 tall with 10 of that being the gap to the next one.
  const rowSize = Size(200, 60);
  const gap = 10.0;

  Finder shadowBox() => find.byWidgetPredicate(
    (widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).boxShadow?.isNotEmpty == true,
  );

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester.widget<DecoratedBox>(shadowBox()).decoration as BoxDecoration;

  Future<void> pumpProxy(WidgetTester tester, {required double lift}) async {
    final decorate = roundedDragProxy(bottomGap: gap);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.fromSize(
              size: rowSize,
              child: decorate(
                const Padding(
                  padding: EdgeInsets.only(bottom: gap),
                  child: Card(child: SizedBox.expand()),
                ),
                0,
                AlwaysStoppedAnimation<double>(lift),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the lifted item is rounded and stops above the row gap', (
    tester,
  ) async {
    await pumpProxy(tester, lift: 1);

    expect(
      decorationOf(tester).borderRadius,
      BorderRadius.circular(AppRadius.card),
    );
    expect(
      tester.getSize(shadowBox()),
      Size(rowSize.width, rowSize.height - gap),
      reason: 'the shadow must end where the card does, not at the row edge',
    );
  });

  testWidgets('the shadow is invisible before the drag starts', (tester) async {
    await pumpProxy(tester, lift: 0);

    final shadow = decorationOf(tester).boxShadow!.single;
    expect(shadow.color.a, 0);
    expect(shadow.blurRadius, 0);
  });

  testWidgets('at full lift the shadow stays inside the guide budget', (
    tester,
  ) async {
    await pumpProxy(tester, lift: 1);

    final shadow = decorationOf(tester).boxShadow!.single;
    expect(shadow.color.a, closeTo(0.08, 0.001));
    expect(shadow.blurRadius, lessThanOrEqualTo(12));
    expect(shadow.offset.dy, lessThanOrEqualTo(4));
  });

  testWidgets('an item without a surface of its own gets a filled one', (
    tester,
  ) async {
    final decorate = roundedDragProxy(radius: AppRadius.input, filled: true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.fromSize(
              size: rowSize,
              child: decorate(
                const Text('종목'),
                0,
                const AlwaysStoppedAnimation<double>(1),
              ),
            ),
          ),
        ),
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.color, isNotNull);
    expect(decoration.borderRadius, BorderRadius.circular(AppRadius.input));
  });
}

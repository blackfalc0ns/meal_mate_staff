import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

void main() {
  testWidgets('BuildContext navigation extensions push and pop routes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Column(
              children: [
                TextButton(
                  onPressed: () => context.pushNamed('/next'),
                  child: const Text('Open'),
                ),
                TextButton(
                  onPressed: () => context.maybePopRoute(),
                  child: const Text('Back'),
                ),
              ],
            );
          },
        ),
        routes: {
          '/next': (context) {
            return Scaffold(
              body: Column(
                children: [
                  const Text('Next'),
                  TextButton(
                    onPressed: () => context.maybePopRoute(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          },
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
  });
}

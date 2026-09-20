import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_mate_delivery/core/widget/custom_progress_indecator.dart';

void main() {
  testWidgets('CustomProgressIndicator renders Lottie animation inside Card', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CustomProgressIndicator(size: 80.0)),
      ),
    );

    expect(find.byType(CustomProgressIndicator), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);
  });
}

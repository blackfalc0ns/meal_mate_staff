import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/splash_screen.dart';
import 'package:meal_mate_delivery/main.dart';

void main() {
  testWidgets('splash screen shows the white logo asset', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    final logoImages = find.byWidgetPredicate((widget) {
      return widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/auth/logo_white.png';
    });

    expect(logoImages, findsOneWidget);
  });

  testWidgets(
    'starts at splash screen, shows role selection sheet, and opens login after confirming',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance timer by 2 seconds to complete splash loading
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify Account Type Selection Sheet is displayed
      expect(find.text('اختر نوع الحساب'), findsOneWidget);
      expect(find.text('سائق'), findsOneWidget);
      expect(find.text('مندوب عمليات'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets(
    'allows switching role to operations representative before confirming',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap on operations role card
      await tester.tap(find.text('مندوب عمليات'));
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
}

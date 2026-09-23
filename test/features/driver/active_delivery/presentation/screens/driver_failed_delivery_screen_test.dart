import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_failed_delivery_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/failed_delivery_actions.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/failed_delivery_header.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/failed_delivery_hero_card.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/failed_delivery_reason_selector.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverFailedDeliveryScreen Widget Tests', () {
    testWidgets('renders all components and submits report', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      String? submittedReason;
      String? submittedNote;
      bool retryCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverFailedDeliveryScreen(
            trip: DriverActiveDeliveryFakeData.defaultTrip,
            onSubmitReport: (reasonId, note) {
              submittedReason = reasonId;
              submittedNote = note;
            },
            onRetry: () => retryCalled = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FailedDeliveryHeader), findsOneWidget);
      expect(find.byType(FailedDeliveryHeroCard), findsOneWidget);
      expect(find.byType(FailedDeliveryReasonSelector), findsOneWidget);
      expect(find.text('العميل لا يجيب على الهاتف'), findsOneWidget);
      expect(find.byType(FailedDeliveryActions), findsOneWidget);

      // Select another reason
      await tester.tap(find.text('العميل رفض استلام الطلب'));
      await tester.pump();

      // Enter notes
      await tester.enterText(find.byType(TextField), 'العميل مسافر');
      await tester.pump();

      // Submit report
      await tester.ensureVisible(find.text('إرسال البلاغ وإرجاع الصندوق'));
      await tester.tap(find.text('إرسال البلاغ وإرجاع الصندوق'));
      await tester.pump();

      expect(submittedReason, equals('customer_refused'));
      expect(submittedNote, equals('العميل مسافر'));

      // Retry
      await tester.ensureVisible(find.text('إعادة المحاولة'));
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();
      expect(retryCalled, isTrue);
    });

    testWidgets('renders properly in English LTR locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: const DriverFailedDeliveryScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Failed Delivery'), findsWidgets);
      expect(find.text('Send Report & Return Box'), findsOneWidget);
      expect(find.text('Retry Delivery'), findsOneWidget);
    });
  });
}

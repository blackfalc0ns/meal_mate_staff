import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_delivery_success_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_success_action_button.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_success_header.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_success_hero_banner.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_success_summary_card.dart';

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

  group('DriverDeliverySuccessScreen Widget Tests', () {
    testWidgets('renders all components and handles confirmation and back', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool confirmedCalled = false;
      bool backCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverDeliverySuccessScreen(
            trip: DriverActiveDeliveryFakeData.defaultTrip,
            onConfirmed: () => confirmedCalled = true,
            onBackToOrders: () => backCalled = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DeliverySuccessHeader), findsOneWidget);
      expect(find.byType(DeliverySuccessHeroBanner), findsOneWidget);
      expect(find.byType(DeliverySuccessSummaryCard), findsOneWidget);
      expect(find.text('#BX-1256'), findsOneWidget);
      expect(find.text('عبدالله العتيبي'), findsOneWidget);
      expect(find.byType(DeliverySuccessActionButton), findsOneWidget);

      await tester.ensureVisible(find.text('تم تأكيد الاستلام'));
      await tester.tap(find.text('تم تأكيد الاستلام'));
      await tester.pump();
      expect(confirmedCalled, isTrue);

      await tester.ensureVisible(find.text('العودة للطلبات'));
      await tester.tap(find.text('العودة للطلبات'));
      await tester.pump();
      expect(backCalled, isTrue);
    });

    testWidgets('renders properly in English LTR locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: const DriverDeliverySuccessScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Order Delivered Successfully'), findsWidgets);
      expect(find.text('Receipt Confirmed'), findsOneWidget);
    });
  });
}

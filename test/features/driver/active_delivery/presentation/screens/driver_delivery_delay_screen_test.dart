import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_delivery_delay_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_delay_actions.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_delay_header.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_delay_hero_banner.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/delivery_delay_info_card.dart';

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

  group('DriverDeliveryDelayScreen Widget Tests', () {
    testWidgets('renders all components and handles actions', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool continueCalled = false;
      bool supportCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverDeliveryDelayScreen(
            trip: DriverActiveDeliveryFakeData.defaultTrip,
            onContinueDelivery: () => continueCalled = true,
            onContactSupport: () => supportCalled = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DeliveryDelayHeader), findsOneWidget);
      expect(find.byType(DeliveryDelayHeroBanner), findsOneWidget);
      expect(find.byType(DeliveryDelayInfoCard), findsOneWidget);
      expect(find.text('#BX-1256'), findsOneWidget);
      expect(find.text('عبدالله العتيبي'), findsOneWidget);
      expect(find.byType(DeliveryDelayActions), findsOneWidget);

      await tester.tap(find.text('متابعة التوصيل'));
      await tester.pump();
      expect(continueCalled, isTrue);

      await tester.tap(find.text('الاتصال بالدعم'));
      await tester.pump();
      expect(supportCalled, isTrue);
    });

    testWidgets('renders properly in English LTR locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: const DriverDeliveryDelayScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Delivery Delay'), findsWidgets);
      expect(find.text('Continue Delivery'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
    });
  });
}

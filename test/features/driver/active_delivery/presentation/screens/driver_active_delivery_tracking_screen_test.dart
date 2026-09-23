import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/repositories/active_delivery_fake_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_active_delivery_tracking_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_tracking_app_bar.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_tracking_bottom_actions.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_tracking_customer_card.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_tracking_map_view.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_tracking_stepper.dart';

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

  group('DriverActiveDeliveryTrackingScreen Widget Tests', () {
    testWidgets(
      'renders all tracking components and responds to action buttons',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);

        bool arrivalCalled = false;
        bool delayCalled = false;
        bool failedCalled = false;

        final repository = ActiveDeliveryFakeRepositoryImpl(
          locationTickInterval: const Duration(seconds: 10),
        );
        addTearDown(repository.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            child: DriverActiveDeliveryTrackingScreen(
              trip: DriverActiveDeliveryFakeData.defaultTrip,
              repository: repository,
              onConfirmArrival: () => arrivalCalled = true,
              onReportDelay: () => delayCalled = true,
              onReportFailed: () => failedCalled = true,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DriverTrackingAppBar), findsOneWidget);
        expect(find.byType(DriverTrackingMapView), findsOneWidget);
        expect(find.byType(GoogleMap), findsOneWidget);
        expect(find.byType(DriverTrackingStepper), findsOneWidget);
        expect(find.byType(DriverTrackingCustomerCard), findsOneWidget);
        expect(find.text('عبدالله العتيبي'), findsOneWidget);
        expect(find.byType(DriverTrackingBottomActions), findsOneWidget);

        // Tap Confirm Arrival
        await tester.ensureVisible(find.text('تأكيد الوصول والتسليم'));
        await tester.tap(find.text('تأكيد الوصول والتسليم'));
        await tester.pump();
        expect(arrivalCalled, isTrue);

        // Tap Delay
        await tester.ensureVisible(find.text('تأخير'));
        await tester.tap(find.text('تأخير'));
        await tester.pump();
        expect(delayCalled, isTrue);

        // Tap Failed Delivery
        await tester.ensureVisible(find.text('تعذر التسليم'));
        await tester.tap(find.text('تعذر التسليم'));
        await tester.pump();
        expect(failedCalled, isTrue);
      },
    );

    testWidgets('renders properly in English LTR locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = ActiveDeliveryFakeRepositoryImpl(
        locationTickInterval: const Duration(seconds: 10),
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: DriverActiveDeliveryTrackingScreen(repository: repository),
        ),
      );
      await tester.pump();

      expect(find.text('Delivery Tracking'), findsOneWidget);
      expect(find.text('Confirm Arrival & Delivery'), findsOneWidget);
      expect(find.text('Delay'), findsOneWidget);
      expect(find.text('Delivery Failed'), findsOneWidget);
    });
  });
}

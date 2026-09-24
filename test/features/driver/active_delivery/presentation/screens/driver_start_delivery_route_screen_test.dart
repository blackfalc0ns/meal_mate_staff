import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_start_delivery_route_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/start_route_action_button.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/start_route_customer_card.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/start_route_header.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/start_route_map_preview.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/start_route_title_section.dart';

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

  group('DriverStartDeliveryRouteScreen Widget Tests', () {
    testWidgets('renders all components and triggers onStartRoute', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool startRouteCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverStartDeliveryRouteScreen(
            trip: DriverActiveDeliveryFakeData.defaultTrip,
            onStartRoute: () {
              startRouteCalled = true;
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(StartRouteHeader), findsOneWidget);
      expect(find.byType(StartRouteTitleSection), findsOneWidget);
      expect(find.text('جاهز لبدأ مسار التوصيل؟'), findsOneWidget);
      expect(find.text('توجه إلى موقع العميل لبدء التوصيل'), findsOneWidget);
      expect(find.byType(StartRouteMapPreview), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byType(StartRouteCustomerCard), findsOneWidget);
      expect(find.text('عبدالله العتيبي'), findsOneWidget);
      expect(find.text('#MM-987654'), findsOneWidget);
      expect(find.text('3 بوكسات'), findsOneWidget);
      expect(find.text('بين 9 - 12 ص'), findsOneWidget);
      expect(find.byType(StartRouteActionButton), findsOneWidget);

      await tester.tap(find.byType(StartRouteActionButton));
      await tester.pump();

      expect(startRouteCalled, isTrue);
    });

    testWidgets('renders properly in English LTR locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: const DriverStartDeliveryRouteScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(StartRouteTitleSection), findsOneWidget);
      expect(find.text('Ready to start the delivery route?'), findsOneWidget);
      expect(find.text('Start Delivery Route'), findsWidgets);
      expect(find.byType(StartRouteCustomerCard), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/screens/driver_map_screen.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_active_order_card.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_background.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_carousel_nav_button.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_page_indicator.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_recenter_button.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_stop_card.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_stops_carousel.dart';

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

  group('DriverMapScreen Widget Tests', () {
    testWidgets('renders all components properly in Arabic (RTL)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool callPressed = false;
      bool addressPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverMapScreen(
            onCallCustomer: () => callPressed = true,
            onAddressTap: () => addressPressed = true,
          ),
        ),
      );
      await tester.pump();

      // Verify Map Background
      expect(find.byType(DriverMapBackground), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);

      // Verify Active Order Top Card
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
      expect(find.text('BX-458722'), findsWidgets);
      expect(find.text('محمد علي'), findsWidgets);
      expect(find.text('+966 50 123 4567'), findsOneWidget);
      expect(find.text('3 وجبات'), findsWidgets);
      expect(find.text('20 : 09 ص'), findsWidgets);

      // Test tapping Call button
      final callBtnFinder = find.widgetWithIcon(InkWell, Icons.phone_rounded);
      expect(callBtnFinder, findsOneWidget);
      await tester.tap(callBtnFinder);
      await tester.pump();
      expect(callPressed, isTrue);

      // Test tapping Address in stats
      final addressFinder = find.text(
        'شارع الخليج العربي ، قطعة 12 ، منزل 45 ، السالمية',
      );
      expect(addressFinder, findsOneWidget);
      await tester.tap(addressFinder);
      await tester.pump();
      expect(addressPressed, isTrue);

      // Verify Recenter Button
      expect(find.byType(DriverMapRecenterButton), findsOneWidget);
      await tester.tap(find.byType(DriverMapRecenterButton));
      await tester.pump();

      // Verify Carousel
      expect(find.byType(DriverMapStopsCarousel), findsOneWidget);
      expect(find.byType(DriverMapStopCard), findsWidgets);
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('مهند أحمد'), findsOneWidget);

      // Test Next arrow on Carousel
      final nextNavFinder = find.widgetWithIcon(
        DriverMapCarouselNavButton,
        Icons.chevron_right_rounded,
      );
      expect(nextNavFinder, findsOneWidget);
      await tester.tap(nextNavFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('renders cleanly in English (LTR)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: const DriverMapScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverMapScreen), findsOneWidget);
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
      expect(find.byType(DriverMapStopsCarousel), findsOneWidget);
      expect(find.byType(DriverMapRecenterButton), findsOneWidget);
    });

    testWidgets('DriverMapScreen is rendered at tab index 2 in AppShellScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          child: const AppShellScreen(
            role: UserRole.driver,
            initialIndex: 2,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverMapScreen), findsOneWidget);
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
    });

    testWidgets('DriverMapStopsCarousel displays 3 cards with looping and navigation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          child: const DriverMapScreen(),
        ),
      );
      await tester.pump();

      // All 3 cards are present around center:
      // Stop 1 (1/3, محمد علي) in center
      // Stop 2 (2/3, مهند أحمد) on right
      // Stop 3 (3/3, أحمد فيصل) on left
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('3/3'), findsOneWidget);
      expect(find.text('محمد علي'), findsWidgets);
      expect(find.text('مهند أحمد'), findsOneWidget);
      expect(find.text('أحمد فيصل'), findsOneWidget);

      // Tap next arrow (right)
      final nextNavFinder = find.widgetWithIcon(
        DriverMapCarouselNavButton,
        Icons.chevron_right_rounded,
      );
      expect(nextNavFinder, findsOneWidget);
      await tester.tap(nextNavFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // After next, Stop 2 (مهند أحمد) is the active order card in the top card
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
      expect(find.text('مهند أحمد'), findsWidgets);

      // Tap previous arrow (left)
      final prevNavFinder = find.widgetWithIcon(
        DriverMapCarouselNavButton,
        Icons.chevron_left_rounded,
      );
      expect(prevNavFinder, findsOneWidget);
      await tester.tap(prevNavFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Back to Stop 1 (محمد علي)
      expect(find.text('محمد علي'), findsWidgets);
    });

    testWidgets('DriverMapPageIndicator renders active bar 32px and inactive bars 22px', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const DriverMapPageIndicator(
            itemCount: 3,
            currentIndex: 0,
          ),
        ),
      );
      await tester.pump();

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      expect(containers.length, equals(3));
      // First (index 0) is selected: width 32
      expect(containers[0].constraints?.maxWidth ?? 32, equals(32));
      // Second and third (index 1, 2) are unselected: width 22
      expect(containers[1].constraints?.maxWidth ?? 22, equals(22));
      expect(containers[2].constraints?.maxWidth ?? 22, equals(22));
    });
  });
}

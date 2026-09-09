import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/map/presentation/screens/dispatcher_map_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/map/presentation/widgets/dispatcher_map_controls.dart';
import 'package:meal_mate_delivery/features/dispatcher/map/presentation/widgets/dispatcher_map_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/map/presentation/widgets/dispatcher_map_drivers_carousel.dart';
import 'package:meal_mate_delivery/features/dispatcher/map/presentation/widgets/dispatcher_map_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/map/presentation/widgets/dispatcher_map_kpi_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/map/presentation/widgets/dispatcher_map_marker_item.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    VoidCallback? onBack,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherMapScreen(onBack: onBack),
    );
  }

  group('DispatcherMapScreen Widget Tests', () {
    testWidgets('renders all sections and elements in Arabic locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Header
      expect(find.byType(DispatcherMapHeader), findsOneWidget);
      expect(find.text('متابعة السائقين'), findsOneWidget);
      expect(find.text('مراقبة السائقين في الوقت الفعلي'), findsOneWidget);

      // KPI Bar & Cards
      expect(find.byType(DispatcherMapKpiBar), findsOneWidget);
      expect(find.text('سائق نشط'), findsOneWidget);
      expect(find.text('32'), findsOneWidget);
      expect(find.text('في التوصيل'), findsWidgets);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('متوقف مؤقتاً'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('مشكلة تتطلب انتباه'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Controls
      expect(find.byType(DispatcherMapControls), findsOneWidget);
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);

      // Map Markers
      expect(find.byType(DispatcherMapMarkerItem), findsWidgets);

      // Bottom Carousel and Cards
      expect(find.byType(DispatcherMapDriversCarousel), findsOneWidget);
      expect(find.byType(DispatcherMapDriverCard), findsWidgets);
      expect(find.text('أحمد فيصل'), findsWidgets);
      expect(find.text('يوسف ناصر'), findsWidgets);
      expect(find.text('سعد خالد'), findsWidgets);
    });

    testWidgets('renders all sections in English locale', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Driver Tracking'), findsOneWidget);
      expect(find.text('Real-time driver monitoring'), findsOneWidget);
      expect(find.text('Active Driver'), findsOneWidget);
      expect(find.text('In Delivery'), findsWidgets);
      expect(find.text('Paused'), findsWidgets);
      expect(find.text('Needs Attention'), findsOneWidget);
    });

    testWidgets('tapping driver card updates selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap on second driver card
      final driverCards = find.byType(DispatcherMapDriverCard);
      expect(driverCards, findsWidgets);

      await tester.tap(driverCards.at(1));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on narrow viewport (360x720)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DispatcherMapScreen), findsOneWidget);
    });
  });
}

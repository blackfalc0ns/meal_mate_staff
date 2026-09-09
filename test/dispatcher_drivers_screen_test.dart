import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/domain/entities/dispatcher_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/screens/dispatcher_drivers_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_area_chips.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_kpi_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_map_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_section_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/drivers/presentation/widgets/dispatcher_drivers_view_switcher.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    ValueChanged<DispatcherDriverEntity>? onSelectDriver,
    VoidCallback? onViewOnMap,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherDriversScreen(
        onSelectDriver: onSelectDriver,
        onViewOnMap: onViewOnMap,
      ),
    );
  }

  group('DispatcherDriversScreen Widget Tests', () {
    testWidgets('renders all sections and elements in Arabic locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Header
      expect(find.byType(DispatcherDriversHeader), findsOneWidget);
      expect(find.text('قائمة السائقين'), findsOneWidget);
      expect(find.text('اختر السائق المناسب لتوزيع الطلبات'), findsOneWidget);

      // View Switcher
      expect(find.byType(DispatcherDriversViewSwitcher), findsOneWidget);
      expect(find.text('حسب المحافظة'), findsOneWidget);
      expect(find.text('كل السائقين'), findsOneWidget);

      // Area Chips
      expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);
      expect(find.text('السالمية'), findsWidgets);
      expect(find.text('حولي'), findsOneWidget);
      expect(find.text('حطين'), findsOneWidget);
      expect(find.text('الفروانية', skipOffstage: false), findsOneWidget);
      expect(find.text('العاصمة', skipOffstage: false), findsOneWidget);

      // KPI Card
      expect(find.byType(DispatcherDriversKpiCard), findsOneWidget);
      expect(find.text('إجمالي السائقين'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DispatcherDriversKpiCard),
          matching: find.text('13'),
        ),
        findsOneWidget,
      );
      expect(find.text('السائقين المتاحين'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DispatcherDriversKpiCard),
          matching: find.text('8'),
        ),
        findsOneWidget,
      );
      expect(find.text('مشغول الآن'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DispatcherDriversKpiCard),
          matching: find.text('5'),
        ),
        findsOneWidget,
      );

      // Section Header
      expect(find.byType(DispatcherDriversSectionHeader), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);
      expect(find.text('ترتيب'), findsOneWidget);

      // Driver Cards
      expect(find.byType(DispatcherDriversCard), findsWidgets);
      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('ID:D-1025'), findsOneWidget);
      expect(find.text('متاح'), findsWidgets);
      expect(find.text('اختيار'), findsWidgets);
      expect(find.text('الطلبات الحالية'), findsWidgets);
      expect(find.text('طلبات مكتملة اليوم'), findsWidgets);
      expect(find.text('الـمـسـافـة مـنـك'), findsWidgets);

      // Map Button
      expect(find.byType(DispatcherDriversMapButton), findsOneWidget);
      expect(find.text('عرض السائقين على الخريطة'), findsOneWidget);
    });

    testWidgets('renders all sections and elements in English locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Drivers List'), findsOneWidget);
      expect(
        find.text('Choose the suitable driver for order dispatch'),
        findsOneWidget,
      );
      expect(find.text('By Area'), findsOneWidget);
      expect(find.text('All Drivers'), findsOneWidget);
      expect(find.text('Total Drivers'), findsOneWidget);
      expect(find.text('Available Drivers'), findsOneWidget);
      expect(find.text('Busy Now'), findsOneWidget);
      expect(find.text('Drivers in السالمية (8)'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('View Drivers on Map'), findsOneWidget);
    });

    testWidgets('switches view mode between By Area and All Drivers', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);

      // Tap All Drivers
      await tester.tap(find.text('كل السائقين'));
      await tester.pumpAndSettle();

      // Area chips should now be hidden
      expect(find.byType(DispatcherDriversAreaChips), findsNothing);
      expect(find.text('جميع السائقين (13)'), findsOneWidget);

      // Switch back to By Area
      await tester.tap(find.text('حسب المحافظة'));
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);
    });

    testWidgets('filters driver list when area chip is selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);

      // Tap Hawally chip
      await tester.tap(find.text('حولي'));
      await tester.pumpAndSettle();

      expect(find.text('السائقين في حولي (2)'), findsOneWidget);
      expect(find.text('يوسف الحربي'), findsOneWidget);
      expect(find.text('عمر القحطاني'), findsOneWidget);
      expect(find.text('أحمد محمد'), findsNothing);
    });

    testWidgets(
      'uses animations package PageTransitionSwitcher when area changes',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.5;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(PageTransitionSwitcher), findsOneWidget);

        // Tap Hawally chip
        await tester.tap(find.text('حولي'));
        // Advance animation partially
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byType(PageTransitionSwitcher), findsOneWidget);
        expect(find.byType(SharedAxisTransition), findsWidgets);

        await tester.pumpAndSettle();
        expect(find.text('السائقين في حولي (2)'), findsOneWidget);
      },
    );

    testWidgets('invokes onSelectDriver when driver select button is tapped', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      DispatcherDriverEntity? selected;
      await tester.pumpWidget(
        buildSubject(onSelectDriver: (d) => selected = d),
      );
      await tester.pumpAndSettle();

      // First driver is Ahmed Mohamed
      final selectButtons = find.text('اختيار');
      expect(selectButtons, findsWidgets);

      await tester.tap(selectButtons.first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'D-1025');
      expect(selected!.name, 'أحمد محمد');
    });

    testWidgets('invokes onViewOnMap when map button is tapped', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool mapTapped = false;
      await tester.pumpWidget(
        buildSubject(onViewOnMap: () => mapTapped = true),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(DispatcherDriversMapButton));
      await tester.tap(find.text('عرض السائقين على الخريطة'));
      await tester.pumpAndSettle();

      expect(mapTapped, isTrue);
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
      expect(find.byType(DispatcherDriversScreen), findsOneWidget);
    });
  });
}

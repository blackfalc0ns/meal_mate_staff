import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_date_filter_chip.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_distribution_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_donut_chart.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_driver_row.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_kpi_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_kpi_list.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_podium_column.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_segmented_tabs.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_tab_item.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_table_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_top_rated_card.dart';

Widget _buildTestableWidget({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6744C2)),
    ),
    onGenerateRoute: RouteGenerator.getRoute,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DispatcherDriverPerformanceScreen Tests', () {
    testWidgets('renders all major components and cards in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          child: const DispatcherDriverPerformanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriverPerformanceScreen), findsOneWidget);
      expect(find.byType(DriverPerformanceHeader), findsOneWidget);
      expect(find.byType(DriverPerformanceDateFilterChip), findsOneWidget);
      expect(find.byType(DriverPerformanceSegmentedTabs), findsOneWidget);
      expect(find.byType(DriverPerformanceKpiList), findsOneWidget);
      expect(find.byType(DriverPerformanceKpiCard), findsNWidgets(5));
      expect(find.byType(DriverPerformanceTableCard), findsOneWidget);
      expect(find.byType(DriverPerformanceDriverRow), findsNWidgets(5));
      expect(find.byType(DriverPerformanceDistributionCard), findsOneWidget);
      expect(find.byType(DriverPerformanceDonutChart), findsOneWidget);
      expect(find.byType(DriverPerformanceTopRatedCard), findsOneWidget);
      expect(find.byType(DriverPerformancePodiumColumn), findsNWidgets(3));

      // Check text in Arabic
      expect(find.text('أداء السائقين'), findsWidgets);
      expect(find.text('آخر 7 أيام'), findsOneWidget);
      expect(find.text('نظرة عامة'), findsOneWidget);
      expect(find.text('مقارنة السائقين'), findsOneWidget);
      expect(find.text('توزيع الأداء'), findsOneWidget);
      expect(find.text('أعلى السائقين تقييماً'), findsOneWidget);
      expect(find.text('أحمد السعيد'), findsWidgets);
      expect(find.text('محمد العنزي'), findsWidgets);
      expect(find.text('يوسف خالد'), findsWidgets);
    });

    testWidgets('renders properly in LTR English without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DispatcherDriverPerformanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriverPerformanceScreen), findsOneWidget);
      expect(find.text('Driver Performance'), findsWidgets);
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Compare Drivers'), findsOneWidget);
      expect(find.text('Performance Distribution'), findsOneWidget);
      expect(find.text('Top Rated Drivers'), findsOneWidget);
    });

    testWidgets('segmented tabs switch between Overview and Compare', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          child: const DispatcherDriverPerformanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final compareTab = find.widgetWithText(
        DriverPerformanceTabItem,
        'مقارنة السائقين',
      );
      expect(compareTab, findsOneWidget);

      await tester.tap(compareTab);
      await tester.pumpAndSettle();
    });
  });
}

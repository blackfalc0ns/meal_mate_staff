import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_comparison_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_delay_level.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_category.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_overview_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_record_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_podium_entry_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_comparison_content.dart';
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

class _ScreenTestRepository implements DriverPerformanceRepository {
  @override
  Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(
    DriverPerformanceQueryEntity query,
  ) async {
    return ApiSuccessResult(data: _createTestOverview());
  }

  @override
  Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(
    DriverPerformanceQueryEntity query,
  ) async {
    return const ApiSuccessResult(
      data: DriverPerformanceComparisonEntity(
        period: DriverPerformancePeriod.last7Days,
        periodText: '1 May - 7 May',
        dateRangeText: '2026-05-01 - 2026-05-07',
        drivers: [
          DriverComparisonRecordEntity(
            driverId: 'drv-1',
            driverCode: 'DRV01',
            fullName: 'Driver One',
            totalAssigned: 50,
            deliveredCount: 48,
            deliveredPercentage: 96,
            onTimePercentage: 94,
            avgDelayMinutes: 4,
            delayLevel: DriverPerformanceDelayLevel.good,
            rating: 4.9,
            failedCount: 1,
            failedPercentage: 2,
            totalDistanceKm: 120,
          ),
        ],
      ),
    );
  }
}

DriverPerformanceOverviewEntity _createTestOverview() {
  return DriverPerformanceOverviewEntity(
    period: DriverPerformancePeriod.last7Days,
    periodText: 'آخر 7 أيام',
    dateRangeText: '2026-05-01 - 2026-05-07',
    kpis: const DriverPerformanceKpisEntity(
      totalBoxes: 128,
      deliveredCount: 118,
      deliveredPercentage: 92.0,
      avgDelayMinutes: 8,
      overallRating: 4.8,
      failedCount: 4,
      failedPercentage: 3.1,
    ),
    distribution: const DriverPerformanceDistributionEntity(
      totalBoxes: 128,
      segments: [
        DriverPerformanceDistributionItemEntity(
          id: '1',
          category: DriverPerformanceDistributionCategory.onTime,
          count: 100,
          percentage: 78.0,
        ),
        DriverPerformanceDistributionItemEntity(
          id: '2',
          category: DriverPerformanceDistributionCategory.late,
          count: 20,
          percentage: 16.0,
        ),
        DriverPerformanceDistributionItemEntity(
          id: '3',
          category: DriverPerformanceDistributionCategory.failed,
          count: 8,
          percentage: 6.0,
        ),
      ],
    ),
    topDrivers: const [
      DriverPodiumEntryEntity(rank: 1, name: 'Top Driver 1', rating: 4.9),
      DriverPodiumEntryEntity(rank: 2, name: 'Top Driver 2', rating: 4.8),
      DriverPodiumEntryEntity(rank: 3, name: 'Top Driver 3', rating: 4.7),
    ],
    driversTable: List.generate(
      5,
      (i) => DriverPerformanceRecordEntity(
        driverId: 'drv-$i',
        driverCode: 'DRV0$i',
        fullName: 'Test Driver $i',
        status: DriverPerformanceDriverStatus.available,
        deliveredCount: 20 + i,
        deliveredPercentage: 90.0,
        avgDelayMinutes: 5,
        delayLevel: DriverPerformanceDelayLevel.good,
        failedDeliveryCount: 1,
        failedDeliveryPercentage: 2.0,
        rating: 4.5 + (i * 0.1),
      ),
    ),
  );
}

Widget _buildTestableWidget({
  required DriverPerformanceViewModel viewModel,
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
    home: DispatcherDriverPerformanceScreen(viewModel: viewModel),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DriverPerformanceViewModel viewModel;

  setUp(() {
    final repository = _ScreenTestRepository();
    viewModel = DriverPerformanceViewModel(
      getOverviewUseCase: GetDriverPerformanceOverviewUseCase(repository),
      getComparisonUseCase: GetDriverPerformanceComparisonUseCase(repository),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('DispatcherDriverPerformanceScreen Tests', () {
    testWidgets('renders all major components and cards in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestableWidget(viewModel: viewModel));
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
      expect(find.text('Test Driver 0'), findsWidgets);
    });

    testWidgets('renders properly in LTR English without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(viewModel: viewModel, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriverPerformanceScreen), findsOneWidget);
      expect(find.text('Driver Performance'), findsWidgets);
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

      await tester.pumpWidget(_buildTestableWidget(viewModel: viewModel));
      await tester.pumpAndSettle();

      final compareTab = find.widgetWithText(
        DriverPerformanceTabItem,
        'مقارنة السائقين',
      );
      expect(compareTab, findsOneWidget);

      await tester.tap(compareTab);
      await tester.pumpAndSettle();

      expect(find.byType(DriverPerformanceComparisonContent), findsOneWidget);
    });
  });
}

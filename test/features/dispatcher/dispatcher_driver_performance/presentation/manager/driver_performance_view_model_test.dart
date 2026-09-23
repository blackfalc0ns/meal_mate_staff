import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
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
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_sort_field.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_tab_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_podium_entry_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model.dart';

class MockDriverPerformanceRepository implements DriverPerformanceRepository {
  int overviewCalls = 0;
  int comparisonCalls = 0;

  bool returnOverviewError = false;
  bool returnComparisonError = false;

  Duration? delay;

  DriverPerformanceOverviewEntity dummyOverview =
      const DriverPerformanceOverviewEntity(
        period: DriverPerformancePeriod.last7Days,
        periodText: 'Last 7 days',
        dateRangeText: 'May 1 - May 7',
        kpis: DriverPerformanceKpisEntity(
          totalBoxes: 10,
          deliveredCount: 8,
          deliveredPercentage: 80,
          avgDelayMinutes: 5,
          overallRating: 4.5,
          failedCount: 1,
          failedPercentage: 10,
        ),
        distribution: DriverPerformanceDistributionEntity(
          totalBoxes: 10,
          segments: [
            DriverPerformanceDistributionItemEntity(
              id: '1',
              category: DriverPerformanceDistributionCategory.onTime,
              count: 10,
              percentage: 100,
            ),
          ],
        ),
        topDrivers: [
          DriverPodiumEntryEntity(rank: 1, name: 'Driver A', rating: 4.8),
        ],
        driversTable: [
          DriverPerformanceRecordEntity(
            driverId: 'dr_1',
            driverCode: 'DR-1',
            fullName: 'Driver One',
            status: DriverPerformanceDriverStatus.available,
            deliveredCount: 15,
            deliveredPercentage: 90.0,
            avgDelayMinutes: 5,
            delayLevel: DriverPerformanceDelayLevel.good,
            failedDeliveryCount: 1,
            failedDeliveryPercentage: 2.0,
            rating: 4.8,
          ),
          DriverPerformanceRecordEntity(
            driverId: 'dr_2',
            driverCode: 'DR-2',
            fullName: 'Driver Two',
            status: DriverPerformanceDriverStatus.onTheWay,
            deliveredCount: 25,
            deliveredPercentage: 95.0,
            avgDelayMinutes: 12,
            delayLevel: DriverPerformanceDelayLevel.warning,
            failedDeliveryCount: 0,
            failedDeliveryPercentage: 0.0,
            rating: 4.2,
          ),
        ],
      );

  DriverPerformanceComparisonEntity dummyComparison =
      const DriverPerformanceComparisonEntity(
        period: DriverPerformancePeriod.last7Days,
        periodText: 'Last 7 days',
        dateRangeText: 'May 1 - May 7',
        drivers: [
          DriverComparisonRecordEntity(
            driverId: 'dr_1',
            driverCode: 'DR-1',
            fullName: 'Driver One',
            totalAssigned: 20,
            deliveredCount: 18,
            deliveredPercentage: 90.0,
            onTimePercentage: 85.0,
            avgDelayMinutes: 6,
            delayLevel: DriverPerformanceDelayLevel.good,
            rating: 4.8,
            failedCount: 1,
            failedPercentage: 5.0,
            totalDistanceKm: 60.0,
          ),
        ],
      );

  @override
  Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(
    DriverPerformanceQueryEntity query,
  ) async {
    overviewCalls++;
    if (delay != null) await Future.delayed(delay!);
    if (returnOverviewError) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Overview server error'),
      );
    }
    return ApiSuccessResult(data: dummyOverview);
  }

  @override
  Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(
    DriverPerformanceQueryEntity query,
  ) async {
    comparisonCalls++;
    if (delay != null) await Future.delayed(delay!);
    if (returnComparisonError) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Comparison server error'),
      );
    }
    return ApiSuccessResult(data: dummyComparison);
  }
}

void main() {
  group('DriverPerformanceViewModel Tests', () {
    late MockDriverPerformanceRepository repository;
    late GetDriverPerformanceOverviewUseCase getOverviewUseCase;
    late GetDriverPerformanceComparisonUseCase getComparisonUseCase;
    late DriverPerformanceViewModel viewModel;

    setUp(() {
      repository = MockDriverPerformanceRepository();
      getOverviewUseCase = GetDriverPerformanceOverviewUseCase(repository);
      getComparisonUseCase = GetDriverPerformanceComparisonUseCase(repository);
      viewModel = DriverPerformanceViewModel(
        getOverviewUseCase: getOverviewUseCase,
        getComparisonUseCase: getComparisonUseCase,
      );
    });

    tearDown(() async {
      await viewModel.close();
    });

    test('initial state and initial Overview request', () async {
      expect(viewModel.state.selectedPeriod, DriverPerformancePeriod.last7Days);
      expect(viewModel.state.selectedTab, DriverPerformanceTabType.overview);
      expect(viewModel.state.overview, isNull);
      expect(viewModel.state.comparison, isNull);

      viewModel.doIntent(const LoadDriverPerformanceOverviewEvent());

      expect(viewModel.state.isOverviewInitialLoading, isTrue);

      await pumpEventQueue();

      expect(viewModel.state.isOverviewInitialLoading, isFalse);
      expect(viewModel.state.overview, isNotNull);
      expect(viewModel.state.hasLoadedOverview, isTrue);
      expect(viewModel.state.comparison, isNull);
      expect(viewModel.state.hasLoadedComparison, isFalse);
      expect(repository.overviewCalls, 1);
      expect(repository.comparisonCalls, 0);
    });

    test(
      'lazy loads comparison on first tab activation and caches on second activation',
      () async {
        viewModel.doIntent(const LoadDriverPerformanceOverviewEvent());
        await pumpEventQueue();

        expect(repository.comparisonCalls, 0);

        // Switch to comparison tab
        viewModel.doIntent(
          const SelectDriverPerformanceTabEvent(
            DriverPerformanceTabType.compareDrivers,
          ),
        );
        expect(viewModel.state.isComparisonInitialLoading, isTrue);

        await pumpEventQueue();

        expect(viewModel.state.isComparisonInitialLoading, isFalse);
        expect(viewModel.state.comparison, isNotNull);
        expect(viewModel.state.hasLoadedComparison, isTrue);
        expect(repository.comparisonCalls, 1);

        // Switch back to overview tab
        viewModel.doIntent(
          const SelectDriverPerformanceTabEvent(
            DriverPerformanceTabType.overview,
          ),
        );
        await pumpEventQueue();
        expect(repository.overviewCalls, 1); // No new overview call

        // Switch back to comparison tab
        viewModel.doIntent(
          const SelectDriverPerformanceTabEvent(
            DriverPerformanceTabType.compareDrivers,
          ),
        );
        await pumpEventQueue();
        expect(repository.comparisonCalls, 1); // Cached! No duplicate request
      },
    );

    test(
      'period change clears old-period data and reloads active tab',
      () async {
        viewModel.doIntent(const LoadDriverPerformanceOverviewEvent());
        await pumpEventQueue();
        expect(viewModel.state.overview, isNotNull);

        // Change period to Last30Days
        viewModel.doIntent(
          const SelectDriverPerformancePeriodEvent(
            DriverPerformancePeriod.last30Days,
          ),
        );
        expect(viewModel.state.overview, isNull);
        expect(viewModel.state.comparison, isNull);
        expect(
          viewModel.state.selectedPeriod,
          DriverPerformancePeriod.last30Days,
        );
        expect(viewModel.state.isOverviewInitialLoading, isTrue);

        await pumpEventQueue();

        expect(viewModel.state.isOverviewInitialLoading, isFalse);
        expect(viewModel.state.overview, isNotNull);
        expect(repository.overviewCalls, 2);
      },
    );

    test('custom date range validation and request', () async {
      viewModel.doIntent(
        SelectDriverPerformanceCustomRangeEvent(
          fromDate: DateTime(2025, 5, 1),
          toDate: DateTime(2025, 5, 10),
        ),
      );

      expect(viewModel.state.selectedPeriod, DriverPerformancePeriod.custom);
      expect(viewModel.state.query.fromDateFormatted, '2025-05-01');
      expect(viewModel.state.query.toDateFormatted, '2025-05-10');

      await pumpEventQueue();

      expect(viewModel.state.overview, isNotNull);
    });

    test(
      'refresh failure preserves existing content and populates refreshFailure',
      () async {
        viewModel.doIntent(const LoadDriverPerformanceOverviewEvent());
        await pumpEventQueue();
        expect(viewModel.state.overview, isNotNull);

        repository.returnOverviewError = true;
        viewModel.doIntent(const RefreshDriverPerformanceEvent());

        expect(viewModel.state.isRefreshing, isTrue);
        await pumpEventQueue();

        expect(viewModel.state.isRefreshing, isFalse);
        expect(viewModel.state.overview, isNotNull); // Kept!
        expect(viewModel.state.refreshFailure, isNotNull);
      },
    );

    test('retry retries only the active tab failed request', () async {
      repository.returnOverviewError = true;
      viewModel.doIntent(const LoadDriverPerformanceOverviewEvent());
      await pumpEventQueue();

      expect(viewModel.state.overviewFailure, isNotNull);
      expect(viewModel.state.overview, isNull);

      repository.returnOverviewError = false;
      viewModel.doIntent(const RetryDriverPerformanceEvent());
      await pumpEventQueue();

      expect(viewModel.state.overview, isNotNull);
      expect(viewModel.state.overviewFailure, isNull);
    });

    test(
      'stale request generation ignored after rapid period changes',
      () async {
        repository.delay = const Duration(milliseconds: 50);

        viewModel.doIntent(
          const SelectDriverPerformancePeriodEvent(
            DriverPerformancePeriod.today,
          ),
        );
        // Immediately switch to ThisMonth before today finishes
        viewModel.doIntent(
          const SelectDriverPerformancePeriodEvent(
            DriverPerformancePeriod.thisMonth,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 120));

        expect(
          viewModel.state.selectedPeriod,
          DriverPerformancePeriod.thisMonth,
        );
        expect(viewModel.state.overview, isNotNull);
      },
    );

    test('local sort toggles direction and sorts driversTable', () async {
      viewModel.doIntent(const LoadDriverPerformanceOverviewEvent());
      await pumpEventQueue();

      // Default sort by rating descending or delivered
      viewModel.doIntent(
        const SortDriverPerformanceTableEvent(
          DriverPerformanceSortField.delivered,
        ),
      );
      // First click sorts descending
      expect(viewModel.state.sortField, DriverPerformanceSortField.delivered);
      expect(
        viewModel.state.sortedDriversTable.first.driverId,
        'dr_2',
      ); // 25 delivered

      // Second click on same field toggles to ascending
      viewModel.doIntent(
        const SortDriverPerformanceTableEvent(
          DriverPerformanceSortField.delivered,
        ),
      );
      expect(viewModel.state.sortAscending, isTrue);
      expect(
        viewModel.state.sortedDriversTable.first.driverId,
        'dr_1',
      ); // 15 delivered
    });
  });
}

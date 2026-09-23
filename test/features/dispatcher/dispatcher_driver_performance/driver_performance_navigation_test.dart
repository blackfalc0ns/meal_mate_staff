import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_comparison_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_delay_level.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_overview_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_record_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_driver_row.dart';

class _NavMockRepository implements DriverPerformanceRepository {
  @override
  Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(
    DriverPerformanceQueryEntity query,
  ) async {
    return const ApiSuccessResult(
      data: DriverPerformanceOverviewEntity(
        period: DriverPerformancePeriod.last7Days,
        periodText: '1 May - 7 May',
        dateRangeText: '2026-05-01 - 2026-05-07',
        kpis: DriverPerformanceKpisEntity(
          totalBoxes: 10,
          deliveredCount: 9,
          deliveredPercentage: 90,
          avgDelayMinutes: 5,
          overallRating: 4.8,
          failedCount: 1,
          failedPercentage: 10,
        ),
        distribution: DriverPerformanceDistributionEntity(
          totalBoxes: 10,
          segments: [],
        ),
        topDrivers: [],
        driversTable: [
          DriverPerformanceRecordEntity(
            driverId: 'target-driver-id-999',
            driverCode: 'DRV999',
            fullName: 'Target Driver',
            status: DriverPerformanceDriverStatus.available,
            deliveredCount: 9,
            deliveredPercentage: 90,
            avgDelayMinutes: 5,
            delayLevel: DriverPerformanceDelayLevel.good,
            failedDeliveryCount: 1,
            failedDeliveryPercentage: 10,
            rating: 4.8,
          ),
        ],
      ),
    );
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
        drivers: [],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'Driver row tap emits exact driverId through onOpenDriverDetails callback',
    (tester) async {
      final repo = _NavMockRepository();
      final vm = DriverPerformanceViewModel(
        getOverviewUseCase: GetDriverPerformanceOverviewUseCase(repo),
        getComparisonUseCase: GetDriverPerformanceComparisonUseCase(repo),
      );

      String? capturedDriverId;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: DispatcherDriverPerformanceScreen(
            viewModel: vm,
            onOpenDriverDetails: (id) => capturedDriverId = id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final row = find.byType(DriverPerformanceDriverRow);
      expect(row, findsOneWidget);

      await tester.tap(row);
      await tester.pumpAndSettle();

      expect(capturedDriverId, 'target-driver-id-999');
      await vm.close();
    },
  );

  testWidgets(
    'DispatcherDriverPerformanceScreen resolves ViewModel from GetIt when not injected',
    (tester) async {
      final repo = _NavMockRepository();
      getIt.registerFactory<DriverPerformanceViewModel>(
        () => DriverPerformanceViewModel(
          getOverviewUseCase: GetDriverPerformanceOverviewUseCase(repo),
          getComparisonUseCase: GetDriverPerformanceComparisonUseCase(repo),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: DispatcherDriverPerformanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriverPerformanceScreen), findsOneWidget);
      expect(find.byType(DriverPerformanceDriverRow), findsOneWidget);
    },
  );
}

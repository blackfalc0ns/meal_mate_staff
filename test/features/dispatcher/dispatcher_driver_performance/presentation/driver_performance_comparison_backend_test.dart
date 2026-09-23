import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_comparison_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_delay_level.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_overview_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/screens/dispatcher_driver_performance_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_comparison_driver_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_comparison_content.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_comparison_shimmer.dart';

class _FakeComparisonRepository implements DriverPerformanceRepository {
  Completer<ApiResult<DriverPerformanceOverviewEntity>>? overviewCompleter;
  Completer<ApiResult<DriverPerformanceComparisonEntity>>? comparisonCompleter;

  ApiResult<DriverPerformanceOverviewEntity>? nextOverviewResult;
  ApiResult<DriverPerformanceComparisonEntity>? nextComparisonResult;

  int overviewCallCount = 0;
  int comparisonCallCount = 0;

  @override
  Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(
    DriverPerformanceQueryEntity query,
  ) async {
    overviewCallCount++;
    if (overviewCompleter != null) {
      return overviewCompleter!.future;
    }
    return nextOverviewResult ??
        const ApiSuccessResult(
          data: DriverPerformanceOverviewEntity(
            period: DriverPerformancePeriod.last7Days,
            periodText: '1 May - 7 May',
            dateRangeText: '2026-05-01 - 2026-05-07',
            kpis: DriverPerformanceKpisEntity(
              totalBoxes: 100,
              deliveredCount: 90,
              deliveredPercentage: 90,
              avgDelayMinutes: 5,
              overallRating: 4.8,
              failedCount: 2,
              failedPercentage: 2,
            ),
            distribution: DriverPerformanceDistributionEntity(
              totalBoxes: 100,
              segments: [],
            ),
            topDrivers: [],
            driversTable: [],
          ),
        );
  }

  @override
  Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(
    DriverPerformanceQueryEntity query,
  ) async {
    comparisonCallCount++;
    if (comparisonCompleter != null) {
      return comparisonCompleter!.future;
    }
    return nextComparisonResult ??
        ApiSuccessResult(data: _createSampleComparison());
  }
}

DriverPerformanceComparisonEntity _createSampleComparison({
  List<DriverComparisonRecordEntity>? drivers,
}) {
  return DriverPerformanceComparisonEntity(
    period: DriverPerformancePeriod.last7Days,
    periodText: '1 May - 7 May',
    dateRangeText: '2026-05-01 - 2026-05-07',
    drivers: drivers ??
        const [
          DriverComparisonRecordEntity(
            driverId: 'drv-1',
            driverCode: 'DRV01',
            fullName: 'Ahmed Comparison',
            avatarUrl: 'https://example.com/avatar1.jpg',
            totalAssigned: 50,
            deliveredCount: 48,
            deliveredPercentage: 96.0,
            onTimePercentage: 94.0,
            avgDelayMinutes: 4,
            delayLevel: DriverPerformanceDelayLevel.good,
            rating: 4.9,
            failedCount: 1,
            failedPercentage: 2.0,
            totalDistanceKm: 120.5,
          ),
          DriverComparisonRecordEntity(
            driverId: 'drv-2',
            driverCode: 'DRV02',
            fullName: 'Omar Comparison',
            avatarUrl: null,
            totalAssigned: 40,
            deliveredCount: 35,
            deliveredPercentage: 87.5,
            onTimePercentage: 80.0,
            avgDelayMinutes: 15,
            delayLevel: DriverPerformanceDelayLevel.warning,
            rating: null, // Null rating test
            failedCount: 3,
            failedPercentage: 7.5,
            totalDistanceKm: null, // Null distance test
          ),
        ],
  );
}

Widget _buildSubject({
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
    home: DispatcherDriverPerformanceScreen(
      viewModel: viewModel,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeComparisonRepository repository;
  late DriverPerformanceViewModel viewModel;

  setUp(() {
    repository = _FakeComparisonRepository();
    viewModel = DriverPerformanceViewModel(
      getOverviewUseCase: GetDriverPerformanceOverviewUseCase(repository),
      getComparisonUseCase: GetDriverPerformanceComparisonUseCase(repository),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('DispatcherDriverPerformanceScreen Comparison Tab Integration', () {
    testWidgets(
      'lazy loads comparison on first tab activation and avoids duplicate request on re-entry',
      (tester) async {
        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        expect(repository.overviewCallCount, 1);
        expect(repository.comparisonCallCount, 0);

        // Switch to Compare tab
        final compareTab = find.text('مقارنة السائقين');
        expect(compareTab, findsOneWidget);
        await tester.tap(compareTab);
        await tester.pumpAndSettle();

        expect(repository.comparisonCallCount, 1);
        expect(find.byType(DriverPerformanceComparisonContent), findsOneWidget);

        // Switch back to Overview
        final overviewTab = find.text('نظرة عامة');
        await tester.tap(overviewTab);
        await tester.pumpAndSettle();

        // Switch to Compare again: should use cached data without calling API
        await tester.tap(compareTab);
        await tester.pumpAndSettle();

        expect(repository.comparisonCallCount, 1);
      },
    );

    testWidgets(
      'renders DriverPerformanceComparisonShimmer while loading comparison data',
      (tester) async {
        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        repository.comparisonCompleter =
            Completer<ApiResult<DriverPerformanceComparisonEntity>>();

        final compareTab = find.text('مقارنة السائقين');
        await tester.tap(compareTab);
        await tester.pump();

        expect(find.byType(DriverPerformanceComparisonShimmer), findsOneWidget);
        expect(find.byType(DriverPerformanceComparisonContent), findsNothing);
      },
    );

    testWidgets(
      'renders ApiErrorWidget on comparison failure and retries on action tap',
      (tester) async {
        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        repository.nextComparisonResult = ApiErrorResult(
          failure: Failure.fromException(
            const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Server error on comparison',
            ),
          ),
        );

        final compareTab = find.text('مقارنة السائقين');
        await tester.tap(compareTab);
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsOneWidget);
        expect(find.byType(DriverPerformanceComparisonContent), findsNothing);

        // Setup success and tap retry
        repository.nextComparisonResult =
            ApiSuccessResult(data: _createSampleComparison());
        final retryBtn = find.byType(AppButton);
        expect(retryBtn, findsOneWidget);

        await tester.tap(retryBtn);
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsNothing);
        expect(find.byType(DriverPerformanceComparisonContent), findsOneWidget);
      },
    );

    testWidgets(
      'renders EmptyStateWidget when comparison drivers list is empty',
      (tester) async {
        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        repository.nextComparisonResult = const ApiSuccessResult(
          data: DriverPerformanceComparisonEntity(
            period: DriverPerformancePeriod.last7Days,
            periodText: '1 May - 7 May',
            dateRangeText: '2026-05-01 - 2026-05-07',
            drivers: [],
          ),
        );

        final compareTab = find.text('مقارنة السائقين');
        await tester.tap(compareTab);
        await tester.pumpAndSettle();

        expect(find.byType(EmptyStateWidget), findsOneWidget);
        expect(find.byType(DriverPerformanceComparisonContent), findsNothing);
      },
    );

    testWidgets(
      'renders all 7 documented metrics and handles null rating/distance fallback',
      (tester) async {
        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        final compareTab = find.text('مقارنة السائقين');
        await tester.tap(compareTab);
        await tester.pumpAndSettle();

        expect(find.byType(DriverComparisonDriverHeader), findsNWidgets(2));
        expect(find.text('Ahmed Comparison'), findsOneWidget);
        expect(find.text('Omar Comparison'), findsOneWidget);

        // Metric values for Ahmed:
        expect(find.text('50'), findsOneWidget); // total assigned
        expect(find.text('48'), findsOneWidget); // delivered count
        expect(find.text('(96%)'), findsOneWidget); // delivered %
        expect(find.text('94%'), findsOneWidget); // on-time %
        expect(find.text('4.9'), findsOneWidget); // rating
        expect(find.text('120.5 km'), findsOneWidget); // distance

        // Omar has null rating and null distance: should show '—'
        expect(find.text('—'), findsNWidgets(2));
      },
    );

    testWidgets(
      'renders cleanly in English LTR without overflow',
      (tester) async {
        await tester.pumpWidget(
          _buildSubject(viewModel: viewModel, locale: const Locale('en')),
        );
        await tester.pumpAndSettle();

        final compareTab = find.text('Compare Drivers');
        await tester.tap(compareTab);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(DriverPerformanceComparisonContent), findsOneWidget);
      },
    );
  });
}

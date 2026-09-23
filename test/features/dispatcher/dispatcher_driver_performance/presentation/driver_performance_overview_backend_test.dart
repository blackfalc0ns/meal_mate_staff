import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
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
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_distribution_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_driver_row.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_kpi_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_overview_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_table_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_top_rated_card.dart';

class _FakeRepository implements DriverPerformanceRepository {
  Completer<ApiResult<DriverPerformanceOverviewEntity>>? overviewCompleter;
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
        ApiSuccessResult(data: _createSampleOverview());
  }

  @override
  Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(
    DriverPerformanceQueryEntity query,
  ) async {
    comparisonCallCount++;
    return nextComparisonResult ??
        const ApiSuccessResult(
          data: DriverPerformanceComparisonEntity(
            period: DriverPerformancePeriod.last7Days,
            periodText: '1 May - 7 May',
            dateRangeText: '2026-05-01 - 2026-05-07',
            drivers: [],
          ),
        );
  }
}

DriverPerformanceOverviewEntity _createSampleOverview({
  List<DriverPodiumEntryEntity>? topDrivers,
  List<DriverPerformanceRecordEntity>? driversTable,
}) {
  return DriverPerformanceOverviewEntity(
    period: DriverPerformancePeriod.last7Days,
    periodText: '1 May - 7 May',
    dateRangeText: '2026-05-01 - 2026-05-07',
    kpis: const DriverPerformanceKpisEntity(
      totalBoxes: 128,
      deliveredCount: 118,
      deliveredPercentage: 92.0,
      avgDelayMinutes: 8,
      overallRating: 4.8,
      failedCount: 4,
      failedPercentage: 3.1,
      totalBoxesText: '128',
      deliveredCountText: '118',
      avgDelayText: '8m',
      overallRatingText: '4.8',
      failedCountText: '4',
    ),
    distribution: const DriverPerformanceDistributionEntity(
      totalBoxes: 128,
      segments: [
        DriverPerformanceDistributionItemEntity(
          id: 'dist-1',
          category: DriverPerformanceDistributionCategory.onTime,
          count: 100,
          percentage: 78.0,
        ),
        DriverPerformanceDistributionItemEntity(
          id: 'dist-2',
          category: DriverPerformanceDistributionCategory.late,
          count: 20,
          percentage: 16.0,
        ),
        DriverPerformanceDistributionItemEntity(
          id: 'dist-3',
          category: DriverPerformanceDistributionCategory.failed,
          count: 8,
          percentage: 6.0,
        ),
      ],
    ),
    topDrivers:
        topDrivers ??
        const [
          DriverPodiumEntryEntity(
            rank: 1,
            name: 'Ahmed Driver',
            rating: 4.9,
            driverId: 'drv-1',
            avatarUrl: 'https://example.com/avatar1.jpg',
          ),
          DriverPodiumEntryEntity(
            rank: 2,
            name: 'Omar Driver',
            rating: 4.8,
            driverId: 'drv-2',
            avatarUrl: null,
          ),
          DriverPodiumEntryEntity(
            rank: 3,
            name: 'Ali Driver',
            rating: 4.7,
            driverId: 'drv-3',
            avatarUrl: null,
          ),
        ],
    driversTable:
        driversTable ??
        const [
          DriverPerformanceRecordEntity(
            driverId: 'drv-1',
            driverCode: 'DRV01',
            fullName: 'Ahmed Driver',
            avatarUrl: 'https://example.com/avatar1.jpg',
            status: DriverPerformanceDriverStatus.available,
            deliveredCount: 60,
            deliveredPercentage: 95.0,
            avgDelayMinutes: 6,
            delayLevel: DriverPerformanceDelayLevel.good,
            failedDeliveryCount: 1,
            failedDeliveryPercentage: 1.5,
            rating: 4.9,
          ),
          DriverPerformanceRecordEntity(
            driverId: 'drv-2',
            driverCode: 'DRV02',
            fullName: 'Omar Driver',
            avatarUrl: null,
            status: DriverPerformanceDriverStatus.onTheWay,
            deliveredCount: 40,
            deliveredPercentage: 89.0,
            avgDelayMinutes: 14,
            delayLevel: DriverPerformanceDelayLevel.warning,
            failedDeliveryCount: 3,
            failedDeliveryPercentage: 6.5,
            rating: 4.5,
          ),
        ],
  );
}

DriverPerformanceOverviewEntity _createEmptyOverview() {
  return const DriverPerformanceOverviewEntity(
    period: DriverPerformancePeriod.last7Days,
    periodText: '1 May - 7 May',
    dateRangeText: '2026-05-01 - 2026-05-07',
    kpis: DriverPerformanceKpisEntity(
      totalBoxes: 0,
      deliveredCount: 0,
      deliveredPercentage: 0,
      avgDelayMinutes: 0,
      overallRating: 0,
      failedCount: 0,
      failedPercentage: 0,
    ),
    distribution: DriverPerformanceDistributionEntity(
      totalBoxes: 0,
      segments: [],
    ),
    topDrivers: [],
    driversTable: [],
  );
}

Widget _buildSubject({
  required DriverPerformanceViewModel viewModel,
  Locale locale = const Locale('ar'),
  ValueChanged<String>? onOpenDriverDetails,
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
      onOpenDriverDetails: onOpenDriverDetails,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeRepository repository;
  late DriverPerformanceViewModel viewModel;

  setUp(() {
    repository = _FakeRepository();
    viewModel = DriverPerformanceViewModel(
      getOverviewUseCase: GetDriverPerformanceOverviewUseCase(repository),
      getComparisonUseCase: GetDriverPerformanceComparisonUseCase(repository),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('DispatcherDriverPerformanceScreen Overview Backend Integration', () {
    testWidgets(
      'renders DriverPerformanceOverviewShimmer while loading initial data',
      (tester) async {
        repository.overviewCompleter =
            Completer<ApiResult<DriverPerformanceOverviewEntity>>();

        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pump();

        expect(find.byType(DriverPerformanceOverviewShimmer), findsOneWidget);
        expect(find.byType(DriverPerformanceTableCard), findsNothing);
      },
    );

    testWidgets(
      'renders ApiErrorWidget on initial failure and retries on action tap',
      (tester) async {
        repository.nextOverviewResult = ApiErrorResult(
          failure: Failure.fromException(
            const ApiException(
              errorType: ApiErrorType.noInternetConnection,
              message: 'No internet connection',
            ),
          ),
        );

        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsOneWidget);
        expect(find.byType(DriverPerformanceTableCard), findsNothing);

        // Prepare success and retry
        repository.nextOverviewResult = ApiSuccessResult(
          data: _createSampleOverview(),
        );
        final retryButton = find.byType(AppButton);
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsNothing);
        expect(find.byType(DriverPerformanceTableCard), findsOneWidget);
      },
    );

    testWidgets('renders EmptyStateWidget when overview data is empty', (
      tester,
    ) async {
      repository.nextOverviewResult = ApiSuccessResult(
        data: _createEmptyOverview(),
      );

      await tester.pumpWidget(_buildSubject(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.byType(DriverPerformanceTableCard), findsNothing);
    });

    testWidgets(
      'renders all 5 KPIs, table card, distribution, and top rated podium',
      (tester) async {
        repository.nextOverviewResult = ApiSuccessResult(
          data: _createSampleOverview(),
        );

        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        expect(find.byType(DriverPerformanceKpiCard), findsNWidgets(5));
        expect(find.text('128'), findsWidgets); // Total boxes KPI and text
        expect(find.byType(DriverPerformanceTableCard), findsOneWidget);
        expect(find.byType(DriverPerformanceDistributionCard), findsOneWidget);
        expect(find.byType(DriverPerformanceTopRatedCard), findsOneWidget);
        expect(find.text('Ahmed Driver'), findsWidgets);
        expect(find.text('Omar Driver'), findsWidgets);
      },
    );

    testWidgets(
      'handles partial top rated podium (e.g. 1 driver) without layout issues',
      (tester) async {
        repository.nextOverviewResult = ApiSuccessResult(
          data: _createSampleOverview(
            topDrivers: const [
              DriverPodiumEntryEntity(
                rank: 1,
                name: 'Sole Winner',
                rating: 5.0,
                driverId: 'drv-sole',
              ),
            ],
          ),
        );

        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        expect(find.byType(DriverPerformanceTopRatedCard), findsOneWidget);
        expect(find.text('Sole Winner'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping table header columns triggers sorting and toggles ascending/descending',
      (tester) async {
        repository.nextOverviewResult = ApiSuccessResult(
          data: _createSampleOverview(),
        );

        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        // Initially sorted by rating descending: Ahmed (4.9), then Omar (4.5)
        final rowsBefore = tester
            .widgetList<DriverPerformanceDriverRow>(
              find.byType(DriverPerformanceDriverRow),
            )
            .toList();
        expect(rowsBefore.first.record.fullName, 'Ahmed Driver');

        // Tap rating column to toggle to ascending
        final ratingHeader = find.text('التقييم');
        expect(ratingHeader, findsOneWidget);
        await tester.tap(ratingHeader);
        await tester.pumpAndSettle();

        final rowsAfter = tester
            .widgetList<DriverPerformanceDriverRow>(
              find.byType(DriverPerformanceDriverRow),
            )
            .toList();
        expect(rowsAfter.first.record.fullName, 'Omar Driver');
      },
    );

    testWidgets(
      'tapping a driver row emits onOpenDriverDetails with exact driverId',
      (tester) async {
        String? selectedId;
        repository.nextOverviewResult = ApiSuccessResult(
          data: _createSampleOverview(),
        );

        await tester.pumpWidget(
          _buildSubject(
            viewModel: viewModel,
            onOpenDriverDetails: (id) => selectedId = id,
          ),
        );
        await tester.pumpAndSettle();

        final firstRow = find.byType(DriverPerformanceDriverRow).first;
        await tester.tap(firstRow);
        await tester.pumpAndSettle();

        expect(selectedId, 'drv-1');
      },
    );

    testWidgets(
      'refresh failure keeps cards visible and renders InlineApiErrorWidget',
      (tester) async {
        repository.nextOverviewResult = ApiSuccessResult(
          data: _createSampleOverview(),
        );

        await tester.pumpWidget(_buildSubject(viewModel: viewModel));
        await tester.pumpAndSettle();

        expect(find.byType(DriverPerformanceTableCard), findsOneWidget);
        expect(find.byType(InlineApiErrorWidget), findsNothing);

        // Next refresh returns error
        repository.nextOverviewResult = ApiErrorResult(
          failure: Failure.fromException(
            const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Server error on refresh',
            ),
          ),
        );

        // Trigger pull to refresh via gesture
        await tester.fling(
          find.byType(DriverPerformanceTableCard),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        // Cards still visible and InlineApiErrorWidget is shown
        expect(find.byType(DriverPerformanceTableCard), findsOneWidget);
        expect(find.byType(InlineApiErrorWidget), findsOneWidget);
      },
    );

    testWidgets('renders cleanly in English LTR without overflow', (
      tester,
    ) async {
      repository.nextOverviewResult = ApiSuccessResult(
        data: _createSampleOverview(),
      );

      await tester.pumpWidget(
        _buildSubject(viewModel: viewModel, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DriverPerformanceTableCard), findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_comparison_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_overview_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart';

class FakeDriverPerformanceRepository implements DriverPerformanceRepository {
  DriverPerformanceOverviewEntity? overviewEntity;
  DriverPerformanceComparisonEntity? comparisonEntity;
  bool returnError = false;

  DriverPerformanceQueryEntity? lastOverviewQuery;
  DriverPerformanceQueryEntity? lastComparisonQuery;

  @override
  Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(DriverPerformanceQueryEntity query) async {
    lastOverviewQuery = query;
    if (returnError) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Overview failed'),
      );
    }
    return ApiSuccessResult(
      data: overviewEntity ??
          DriverPerformanceOverviewEntity(
            period: query.period,
            periodText: 'Text',
            dateRangeText: 'Range',
            kpis: const DriverPerformanceKpisEntity(
              totalBoxes: 10,
              deliveredCount: 8,
              deliveredPercentage: 80,
              avgDelayMinutes: 5,
              overallRating: 4.5,
              failedCount: 1,
              failedPercentage: 10,
            ),
            distribution: const DriverPerformanceDistributionEntity(
              totalBoxes: 10,
              segments: <DriverPerformanceDistributionItemEntity>[],
            ),
            topDrivers: const [],
            driversTable: const [],
          ),
    );
  }

  @override
  Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(DriverPerformanceQueryEntity query) async {
    lastComparisonQuery = query;
    if (returnError) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Comparison failed'),
      );
    }
    return ApiSuccessResult(
      data: comparisonEntity ??
          DriverPerformanceComparisonEntity(
            period: query.period,
            periodText: 'Text',
            dateRangeText: 'Range',
            drivers: const [],
          ),
    );
  }
}

void main() {
  group('DriverPerformance UseCases Tests', () {
    late FakeDriverPerformanceRepository repository;
    late GetDriverPerformanceOverviewUseCase getOverviewUseCase;
    late GetDriverPerformanceComparisonUseCase getComparisonUseCase;

    setUp(() {
      repository = FakeDriverPerformanceRepository();
      getOverviewUseCase = GetDriverPerformanceOverviewUseCase(repository);
      getComparisonUseCase = GetDriverPerformanceComparisonUseCase(repository);
    });

    test('GetDriverPerformanceOverviewUseCase validates invalid custom date range locally without calling repository', () async {
      const invalidQuery = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.custom,
        fromDate: null,
        toDate: null,
      );

      final result = await getOverviewUseCase(invalidQuery);

      expect(result, isA<ApiErrorResult>());
      final error = result as ApiErrorResult;
      expect(error.failure.exception.errorType, ApiErrorType.validationError);
      expect(repository.lastOverviewQuery, isNull);
    });

    test('GetDriverPerformanceOverviewUseCase forwards valid query to repository', () async {
      final validQuery = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.custom,
        fromDate: DateTime(2025, 5, 1),
        toDate: DateTime(2025, 5, 7),
      );

      final result = await getOverviewUseCase(validQuery);

      expect(result, isA<ApiSuccessResult>());
      expect(repository.lastOverviewQuery, validQuery);
    });

    test('GetDriverPerformanceComparisonUseCase validates invalid custom date range locally', () async {
      final invalidQuery = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.custom,
        fromDate: DateTime(2025, 5, 10),
        toDate: DateTime(2025, 5, 1),
      );

      final result = await getComparisonUseCase(invalidQuery);

      expect(result, isA<ApiErrorResult>());
      final error = result as ApiErrorResult;
      expect(error.failure.exception.errorType, ApiErrorType.validationError);
      expect(repository.lastComparisonQuery, isNull);
    });

    test('GetDriverPerformanceComparisonUseCase forwards valid query to repository', () async {
      const validQuery = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.last30Days,
      );

      final result = await getComparisonUseCase(validQuery);

      expect(result, isA<ApiSuccessResult>());
      expect(repository.lastComparisonQuery, validQuery);
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/data_source/driver_performance_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_comparison_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_overview_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/repo/driver_performance_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_query_entity.dart';

class FakeDriverPerformanceRemoteDataSource
    implements DriverPerformanceRemoteDataSource {
  DriverPerformanceOverviewResponseDto? overviewResponse;
  DriverPerformanceComparisonResponseDto? comparisonResponse;
  Exception? exceptionToThrow;

  DriverPerformanceQueryEntity? capturedOverviewQuery;
  DriverPerformanceQueryEntity? capturedComparisonQuery;

  @override
  Future<DriverPerformanceOverviewResponseDto> getOverview(
    DriverPerformanceQueryEntity query,
  ) async {
    capturedOverviewQuery = query;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return overviewResponse ?? const DriverPerformanceOverviewResponseDto();
  }

  @override
  Future<DriverPerformanceComparisonResponseDto> getComparison(
    DriverPerformanceQueryEntity query,
  ) async {
    capturedComparisonQuery = query;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return comparisonResponse ?? const DriverPerformanceComparisonResponseDto();
  }
}

void main() {
  group('DriverPerformanceRepositoryImpl Tests', () {
    late FakeDriverPerformanceRemoteDataSource remoteDataSource;
    late DriverPerformanceRepositoryImpl repository;

    setUp(() {
      remoteDataSource = FakeDriverPerformanceRemoteDataSource();
      repository = DriverPerformanceRepositoryImpl(remoteDataSource);
    });

    test(
      'getOverview success returns ApiSuccessResult with mapped entity',
      () async {
        remoteDataSource.overviewResponse =
            const DriverPerformanceOverviewResponseDto(
              period: 'Last7Days',
              periodText: 'Last 7 days',
              kpis: DriverPerformanceKpisResponseDto(totalBoxes: 100),
            );

        const query = DriverPerformanceQueryEntity(
          period: DriverPerformancePeriod.last7Days,
        );
        final result = await repository.getOverview(query);

        expect(result, isA<ApiSuccessResult>());
        final success = result as ApiSuccessResult;
        expect(success.data.period, DriverPerformancePeriod.last7Days);
        expect(success.data.kpis.totalBoxes, 100);
        expect(
          remoteDataSource.capturedOverviewQuery?.period,
          DriverPerformancePeriod.last7Days,
        );
      },
    );

    test('getOverview error wraps in ApiErrorResult and Failure', () async {
      remoteDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/dispatcher/performance/overview',
        ),
        type: DioExceptionType.connectionTimeout,
      );

      const query = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.last7Days,
      );
      final result = await repository.getOverview(query);

      expect(result, isA<ApiErrorResult>());
    });

    test(
      'getComparison success returns ApiSuccessResult with mapped entity',
      () async {
        remoteDataSource.comparisonResponse =
            const DriverPerformanceComparisonResponseDto(
              period: 'ThisMonth',
              drivers: [
                DriverComparisonDriverResponseDto(
                  driverId: 'drv-1',
                  fullName: 'Driver One',
                ),
              ],
            );

        const query = DriverPerformanceQueryEntity(
          period: DriverPerformancePeriod.thisMonth,
        );
        final result = await repository.getComparison(query);

        expect(result, isA<ApiSuccessResult>());
        final success = result as ApiSuccessResult;
        expect(success.data.period, DriverPerformancePeriod.thisMonth);
        expect(success.data.drivers.length, 1);
        expect(success.data.drivers.first.driverId, 'drv-1');
      },
    );

    test('getComparison error wraps in ApiErrorResult', () async {
      remoteDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/dispatcher/performance/comparison',
        ),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(
            path: '/api/v1/dispatcher/performance/comparison',
          ),
          statusCode: 500,
        ),
      );

      const query = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.thisMonth,
      );
      final result = await repository.getComparison(query);

      expect(result, isA<ApiErrorResult>());
    });
  });
}

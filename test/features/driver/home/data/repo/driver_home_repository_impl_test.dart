import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/home/data/data_source/driver_home_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/home/data/models/response/driver_home_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/home/data/repo/driver_home_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';

class _FakeRemoteDataSource implements DriverHomeRemoteDataSource {
  DriverHomeResponseDto? response;
  Exception? exception;

  @override
  Future<DriverHomeResponseDto> getDriverHome() async {
    if (exception != null) {
      throw exception!;
    }
    return response!;
  }
}

void main() {
  group('DriverHomeRepositoryImpl', () {
    late _FakeRemoteDataSource fakeRemoteDataSource;
    late DriverHomeRepositoryImpl repository;

    setUp(() {
      fakeRemoteDataSource = _FakeRemoteDataSource();
      repository = DriverHomeRepositoryImpl(fakeRemoteDataSource);
    });

    test('returns ApiSuccessResult when remote data source succeeds', () async {
      fakeRemoteDataSource.response = const DriverHomeResponseDto(
        driverId: 'drv-1',
        driverName: 'سائق تجريبي',
        driverCode: 'DRV01',
        shiftStatus: 'Active',
        isAvailable: true,
        currentStatusText: 'متاح',
      );

      final result = await repository.getDriverHome();

      expect(result, isA<ApiSuccessResult<DriverHomeEntity>>());
      final entity = (result as ApiSuccessResult<DriverHomeEntity>).data;
      expect(entity.driverId, 'drv-1');
      expect(entity.driverName, 'سائق تجريبي');
      expect(entity.shiftStatus, DriverShiftStatus.active);
      expect(entity.isAvailable, true);
    });

    test(
      'returns ApiErrorResult with Failure when DioException occurs',
      () async {
        fakeRemoteDataSource.exception = DioException(
          requestOptions: RequestOptions(path: '/api/v1/driver/home'),
          type: DioExceptionType.connectionTimeout,
        );

        final result = await repository.getDriverHome();

        expect(result, isA<ApiErrorResult<DriverHomeEntity>>());
        final failure = (result as ApiErrorResult<DriverHomeEntity>).failure;
        expect(failure, isA<Failure>());
      },
    );
  });
}

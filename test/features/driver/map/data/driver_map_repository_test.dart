import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/map/data/data_source/driver_map_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/map/data/models/response/driver_map_route_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/map/data/repo/driver_map_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/repo/driver_map_repository.dart';

class _FakeDriverMapRemoteDataSource implements DriverMapRemoteDataSource {
  String? lastFocusedStopId;
  DriverMapRouteResponseDto successResponse = const DriverMapRouteResponseDto(
    tripId: 'trip-1',
    tripCode: 'TRP-1',
  );
  DioException? errorToThrow;

  @override
  Future<DriverMapRouteResponseDto> getDriverMapRoute({
    String? focusedStopId,
  }) async {
    lastFocusedStopId = focusedStopId;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return successResponse;
  }
}

void main() {
  late _FakeDriverMapRemoteDataSource fakeRemoteDataSource;
  late DriverMapRepository repository;

  setUp(() {
    fakeRemoteDataSource = _FakeDriverMapRemoteDataSource();
    repository = DriverMapRepositoryImpl(fakeRemoteDataSource);
  });

  group('DriverMapRepository', () {
    test('returns ApiSuccessResult when remote data source succeeds', () async {
      fakeRemoteDataSource.successResponse = const DriverMapRouteResponseDto(
        tripId: 'trip-1',
        tripCode: 'TRP-1',
      );

      final result = await repository.getDriverMapRoute();

      expect(result, isA<ApiSuccessResult<DriverMapRouteEntity>>());
      final entity = (result as ApiSuccessResult<DriverMapRouteEntity>).data;
      expect(entity.tripId, 'trip-1');
      expect(entity.tripCode, 'TRP-1');
    });

    test('returns ApiErrorResult with code DriverTrip.NotFound on 404 trip not found', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
          statusCode: 404,
          data: {
            'title': 'غير موجود',
            'status': 404,
            'extensions': {'code': 'DriverTrip.NotFound'},
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.getDriverMapRoute();

      expect(result, isA<ApiErrorResult<DriverMapRouteEntity>>());
      final failure = (result as ApiErrorResult<DriverMapRouteEntity>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).code, 'DriverTrip.NotFound');
    });

    test('returns ApiErrorResult with code DriverMap.StopNotFound on 404 stop not found', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
          statusCode: 404,
          data: {
            'title': 'غير موجود',
            'status': 404,
            'extensions': {'code': 'DriverMap.StopNotFound'},
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.getDriverMapRoute(focusedStopId: 'invalid-stop');

      expect(result, isA<ApiErrorResult<DriverMapRouteEntity>>());
      final failure = (result as ApiErrorResult<DriverMapRouteEntity>).failure;
      expect((failure as ServerFailure).code, 'DriverMap.StopNotFound');
    });
  });
}

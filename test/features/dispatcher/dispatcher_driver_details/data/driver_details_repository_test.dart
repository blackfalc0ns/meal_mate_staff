import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/data_source/driver_details_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/models/response/driver_active_boxes_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/models/response/driver_current_location_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/models/response/driver_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/repo/driver_details_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/repo/driver_details_repository.dart';

class FakeDriverDetailsRemoteDataSource
    implements DriverDetailsRemoteDataSource {
  DriverDetailsResponseDto? detailsResponse;
  DriverActiveBoxesResponseDto? activeBoxesResponse;
  DriverCurrentLocationResponseDto? currentLocationResponse;
  Exception? errorToThrow;

  @override
  Future<DriverDetailsResponseDto> getDetails(String driverId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return detailsResponse ?? const DriverDetailsResponseDto();
  }

  @override
  Future<DriverActiveBoxesResponseDto> getActiveBoxes(String driverId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return activeBoxesResponse ?? const DriverActiveBoxesResponseDto();
  }

  @override
  Future<DriverCurrentLocationResponseDto> getCurrentLocation(
    String driverId,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return currentLocationResponse ?? const DriverCurrentLocationResponseDto();
  }
}

void main() {
  late FakeDriverDetailsRemoteDataSource remoteDataSource;
  late DriverDetailsRepository repository;
  const driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';

  setUp(() {
    remoteDataSource = FakeDriverDetailsRemoteDataSource();
    repository = DriverDetailsRepositoryImpl(remoteDataSource);
  });

  group('DriverDetailsRepositoryImpl', () {
    test('getDetails returns ApiSuccessResult on remote success', () async {
      remoteDataSource.detailsResponse = const DriverDetailsResponseDto(
        driver: DriverProfileDto(
          driverId: driverId,
          driverCode: 'DR-1025',
          fullName: 'أحمد السعيد',
        ),
        kpis: DriverKpisDto(activeBoxesCount: 2),
      );

      final result = await repository.getDetails(driverId);

      expect(result, isA<ApiSuccessResult>());
      final entity = (result as ApiSuccessResult).data;
      expect(entity.driver.driverId, driverId);
      expect(entity.driver.driverCode, 'DR-1025');
      expect(entity.kpis.activeBoxesCount, 2);
    });

    test('getDetails returns ApiErrorResult when remote throws DioException', () async {
      remoteDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/details'),
        type: DioExceptionType.connectionTimeout,
        error: 'Connection timeout',
      );

      final result = await repository.getDetails(driverId);

      expect(result, isA<ApiErrorResult>());
      final error = result as ApiErrorResult;
      expect(error.failure, isNotNull);
    });

    test('getActiveBoxes returns ApiSuccessResult with empty list when boxes is null', () async {
      remoteDataSource.activeBoxesResponse = const DriverActiveBoxesResponseDto(
        totalCount: 0,
        boxes: null,
      );

      final result = await repository.getActiveBoxes(driverId);

      expect(result, isA<ApiSuccessResult>());
      final list = (result as ApiSuccessResult).data;
      expect(list, isEmpty);
    });

    test('getCurrentLocation returns ApiSuccessResult with offline coordinates', () async {
      remoteDataSource.currentLocationResponse =
          const DriverCurrentLocationResponseDto(
        latitude: null,
        longitude: null,
        statusBadgeText: 'غير متصل',
      );

      final result = await repository.getCurrentLocation(driverId);

      expect(result, isA<ApiSuccessResult>());
      final entity = (result as ApiSuccessResult).data;
      expect(entity.isOffline, isTrue);
      expect(entity.latitude, isNull);
    });
  });
}

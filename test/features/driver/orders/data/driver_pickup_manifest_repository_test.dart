import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/data_source/driver_pickup_manifest_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_pickup_manifest_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/repo/driver_pickup_manifest_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_boxes_filter_type.dart';

class _FakeManifestRemoteDataSource
    implements DriverPickupManifestRemoteDataSource {
  String? requestedFilter;
  bool shouldThrowDioError = false;
  DriverPickupManifestResponseDto response =
      const DriverPickupManifestResponseDto(
        tripId: 'trip-repo-1',
        totalBoxesCount: 5,
      );

  @override
  Future<DriverPickupManifestResponseDto> getDriverPickupManifest({
    required String statusFilter,
  }) async {
    requestedFilter = statusFilter;
    if (shouldThrowDioError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/pickup/manifest'),
        type: DioExceptionType.connectionTimeout,
      );
    }
    return response;
  }
}

void main() {
  group('DriverPickupManifestRepositoryImpl', () {
    test(
      'calls remote data source with wireValue and returns mapped entity on success',
      () async {
        final fakeDataSource = _FakeManifestRemoteDataSource();
        final repository = DriverPickupManifestRepositoryImpl(fakeDataSource);

        final result = await repository.getDriverPickupManifest(
          filter: DriverBoxesFilterType.pendingScan,
        );

        expect(fakeDataSource.requestedFilter, 'PendingScan');
        expect(result, isA<ApiSuccessResult>());
        final success = result as ApiSuccessResult;
        expect(success.data.tripId, 'trip-repo-1');
        expect(success.data.totalBoxesCount, 5);
      },
    );

    test(
      'wraps exceptions with safeApiCall returning ApiErrorResult',
      () async {
        final fakeDataSource = _FakeManifestRemoteDataSource()
          ..shouldThrowDioError = true;
        final repository = DriverPickupManifestRepositoryImpl(fakeDataSource);

        final result = await repository.getDriverPickupManifest(
          filter: DriverBoxesFilterType.all,
        );

        expect(result, isA<ApiErrorResult>());
        final errorResult = result as ApiErrorResult;
        expect(errorResult.failure, isA<ServerFailure>());
      },
    );
  });
}

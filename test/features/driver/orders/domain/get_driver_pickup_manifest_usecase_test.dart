import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_boxes_filter_type.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_pickup_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/repo/driver_pickup_manifest_repository.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/get_driver_pickup_manifest_usecase.dart';

class _FakeManifestRepository implements DriverPickupManifestRepository {
  DriverBoxesFilterType? requestedFilter;
  ApiResult<DriverPickupManifestEntity> result = const ApiSuccessResult(
    data: DriverPickupManifestEntity(
      tripId: 'trip-usecase-1',
      tripCode: 'TRIP-1',
      driverId: 'drv-1',
      driverName: 'Driver Name',
      totalBoxesCount: 4,
      totalMealsCount: 16,
      pendingScanBoxesCount: 2,
      pickedUpBoxesCount: 2,
      allBoxesPickedUp: false,
      canStartTrip: false,
      boxes: [],
    ),
  );

  @override
  Future<ApiResult<DriverPickupManifestEntity>> getDriverPickupManifest({
    required DriverBoxesFilterType filter,
  }) async {
    requestedFilter = filter;
    return result;
  }
}

void main() {
  group('GetDriverPickupManifestUseCase', () {
    test('forwards filter to repository and returns ApiResult', () async {
      final fakeRepo = _FakeManifestRepository();
      final useCase = GetDriverPickupManifestUseCase(fakeRepo);

      final result = await useCase.call(DriverBoxesFilterType.pickedUp);

      expect(fakeRepo.requestedFilter, DriverBoxesFilterType.pickedUp);
      expect(result, isA<ApiSuccessResult<DriverPickupManifestEntity>>());
      final success = result as ApiSuccessResult<DriverPickupManifestEntity>;
      expect(success.data.tripId, 'trip-usecase-1');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/data_source/driver_pickup_manifest_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_pickup_manifest_response_dto.dart';

class _FakeApiServices implements ApiServices {
  String? lastStatusFilter;
  DriverPickupManifestResponseDto response =
      const DriverPickupManifestResponseDto(tripId: 'trip-1');

  @override
  Future<DriverPickupManifestResponseDto> getDriverPickupManifest(
    String statusFilter,
  ) async {
    lastStatusFilter = statusFilter;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DriverPickupManifestRemoteDataSourceImpl', () {
    test('forwards statusFilter to ApiServices unchanged', () async {
      final fakeApi = _FakeApiServices();
      final dataSource = DriverPickupManifestRemoteDataSourceImpl(fakeApi);

      final result = await dataSource.getDriverPickupManifest(
        statusFilter: 'PickedUp',
      );

      expect(fakeApi.lastStatusFilter, 'PickedUp');
      expect(result.tripId, 'trip-1');
    });
  });
}

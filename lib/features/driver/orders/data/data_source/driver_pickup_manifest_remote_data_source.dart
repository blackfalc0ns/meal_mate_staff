import '../models/response/driver_pickup_manifest_response_dto.dart';

abstract interface class DriverPickupManifestRemoteDataSource {
  Future<DriverPickupManifestResponseDto> getDriverPickupManifest({
    required String statusFilter,
  });
}

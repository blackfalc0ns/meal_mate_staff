import '../../../../../core/network/api_results.dart';
import '../entities/driver_boxes_filter_type.dart';
import '../entities/driver_pickup_manifest_entity.dart';

abstract interface class DriverPickupManifestRepository {
  Future<ApiResult<DriverPickupManifestEntity>> getDriverPickupManifest({
    required DriverBoxesFilterType filter,
  });
}

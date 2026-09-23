import '../../../../../core/network/api_results.dart';
import '../entities/driver_active_box_entity.dart';
import '../entities/driver_current_location_entity.dart';
import '../entities/driver_details_entity.dart';

abstract interface class DriverDetailsRepository {
  Future<ApiResult<DriverDetailsEntity>> getDetails(String driverId);
  Future<ApiResult<List<DriverActiveBoxEntity>>> getActiveBoxes(
    String driverId,
  );
  Future<ApiResult<DriverCurrentLocationEntity>> getCurrentLocation(
    String driverId,
  );
}

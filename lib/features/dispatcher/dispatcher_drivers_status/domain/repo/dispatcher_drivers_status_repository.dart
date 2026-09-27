import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_driver_details_entity.dart';
import '../entities/dispatcher_drivers_status_query_entity.dart';
import '../entities/dispatcher_drivers_status_summary_entity.dart';
import '../entities/update_driver_availability_request_entity.dart';
import '../entities/update_driver_availability_result_entity.dart';

abstract interface class DispatcherDriversStatusRepository {
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]);

  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(UpdateDriverAvailabilityRequestEntity request);

  Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(
    String driverId,
  );

  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates;

  Future<void> acquireRealtime(String ownerId);

  Future<void> releaseRealtime(String ownerId);
}

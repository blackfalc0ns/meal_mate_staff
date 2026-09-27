import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_drivers_status_summary_entity.dart';

abstract interface class DispatcherDriversStatusRepository {
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus();
  Future<ApiResult<bool>> toggleDriverAvailability(String driverId, bool isAvailable);
}

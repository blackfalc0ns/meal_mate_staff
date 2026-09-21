import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_home_map_driver_pin_entity.dart';
import '../entities/dispatcher_home_overview_entity.dart';

abstract class DispatcherHomeRepository {
  Future<ApiResult<DispatcherHomeOverviewEntity>> getOverview();
  Future<ApiResult<List<DispatcherHomeMapDriverPinEntity>>> getLiveDrivers();
}

import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/driver_map_route_entity.dart';

abstract class DriverMapRepository {
  Future<ApiResult<DriverMapRouteEntity>> getDriverMapRoute({
    String? focusedStopId,
  });
}

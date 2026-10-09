import '../../../features/driver/active_delivery/domain/entities/driver_deliver_result_entity.dart';
import '../../../features/driver/active_delivery/domain/entities/driver_start_delivery_result_entity.dart';
import '../../../features/driver/map/domain/entities/driver_map_route_entity.dart';
import '../../../features/driver/map/domain/entities/driver_map_stop_entity.dart';

class DriverActiveDeliveryRouteArguments {
  const DriverActiveDeliveryRouteArguments({
    this.stopId,
    this.startResult,
    this.startedRoute,
    this.tripId,
    this.deliveryResult,
    this.completedStop,
  });

  final String? stopId;
  final DriverStartDeliveryResultEntity? startResult;
  final DriverMapRouteEntity? startedRoute;
  final String? tripId;
  final DriverDeliverResultEntity? deliveryResult;
  final DriverMapStopEntity? completedStop;
}

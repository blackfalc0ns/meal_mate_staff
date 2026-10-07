import '../../../features/driver/active_delivery/domain/entities/driver_deliver_result_entity.dart';
import '../../../features/driver/map/domain/entities/driver_map_stop_entity.dart';

class DriverActiveDeliveryRouteArguments {
  const DriverActiveDeliveryRouteArguments({
    this.stopId,
    this.tripId,
    this.deliveryResult,
    this.completedStop,
  });

  final String? stopId;
  final String? tripId;
  final DriverDeliverResultEntity? deliveryResult;
  final DriverMapStopEntity? completedStop;
}

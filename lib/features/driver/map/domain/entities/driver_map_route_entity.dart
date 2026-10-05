import 'driver_map_navigation_entity.dart';
import 'driver_map_stop_entity.dart';

class DriverMapRouteEntity {
  const DriverMapRouteEntity({
    required this.tripId,
    required this.tripCode,
    this.totalStopsCount = 0,
    this.completedStopsCount = 0,
    required this.focusedStop,
    required this.stops,
    this.navigation,
  });

  final String tripId;
  final String tripCode;
  final int totalStopsCount;
  final int completedStopsCount;
  final DriverMapStopEntity focusedStop;
  final List<DriverMapStopEntity> stops;
  final DriverMapNavigationEntity? navigation;
}

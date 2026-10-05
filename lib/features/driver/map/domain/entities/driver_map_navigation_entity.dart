import 'driver_map_location_entity.dart';
import 'driver_map_route_status.dart';
import 'driver_map_unavailable_reason.dart';

class DriverMapNavigationEntity {
  const DriverMapNavigationEntity({
    this.destinationStopId,
    this.origin,
    this.destination,
    required this.routeStatus,
    this.unavailableReason,
    this.encodedPolyline,
    this.polylineEncoding = 'google_polyline5',
    this.distanceMeters,
    this.durationSeconds,
    this.estimatedArrivalAtUtc,
    this.calculatedAtUtc,
    this.googleMapsUrl,
    required this.canNavigate,
  });

  final String? destinationStopId;
  final DriverMapLocationEntity? origin;
  final DriverMapLocationEntity? destination;
  final DriverMapRouteStatus routeStatus;
  final DriverMapUnavailableReason? unavailableReason;
  final String? encodedPolyline;
  final String polylineEncoding;
  final int? distanceMeters;
  final int? durationSeconds;
  final DateTime? estimatedArrivalAtUtc;
  final DateTime? calculatedAtUtc;
  final String? googleMapsUrl;
  final bool canNavigate;

  bool get isReady => routeStatus == DriverMapRouteStatus.ready;
  bool get isUnavailable => routeStatus == DriverMapRouteStatus.unavailable;
  bool get isCompleted => routeStatus == DriverMapRouteStatus.completed;
}

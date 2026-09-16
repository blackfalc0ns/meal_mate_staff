import 'dispatcher_map_driver_status.dart';

class DispatcherMapDriverMarkerEntity {
  const DispatcherMapDriverMarkerEntity({
    required this.id,
    required this.name,
    required this.boxId,
    required this.status,
    required this.locationName,
    this.remainingDistanceKm,
    required this.avatarUrl,
    required this.mapRelativeX,
    required this.mapRelativeY,
  });

  final String id;
  final String name;
  final String boxId;
  final DispatcherMapDriverStatus status;
  final String locationName;
  final double? remainingDistanceKm;
  final String avatarUrl;
  final double mapRelativeX;
  final double mapRelativeY;
}

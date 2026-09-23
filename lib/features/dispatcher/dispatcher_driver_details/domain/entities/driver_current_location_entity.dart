import 'driver_location_point_entity.dart';

class DriverCurrentLocationEntity {
  const DriverCurrentLocationEntity({
    this.latitude,
    this.longitude,
    this.heading,
    this.speed,
    this.destinationLatitude,
    this.destinationLongitude,
    required this.statusBadgeText,
    required this.timeAgoText,
    required this.streetName,
    required this.areaName,
    this.routePoints = const [],
    this.recordedAt,
  });

  final double? latitude;
  final double? longitude;
  final double? heading;
  final double? speed;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String statusBadgeText;
  final String timeAgoText;
  final String streetName;
  final String areaName;
  final List<DriverLocationPointEntity> routePoints;
  final String? recordedAt;

  bool get isOffline => latitude == null || longitude == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverCurrentLocationEntity &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          heading == other.heading &&
          speed == other.speed &&
          destinationLatitude == other.destinationLatitude &&
          destinationLongitude == other.destinationLongitude &&
          statusBadgeText == other.statusBadgeText &&
          timeAgoText == other.timeAgoText &&
          streetName == other.streetName &&
          areaName == other.areaName &&
          recordedAt == other.recordedAt;

  @override
  int get hashCode => Object.hash(
    latitude,
    longitude,
    heading,
    speed,
    destinationLatitude,
    destinationLongitude,
    statusBadgeText,
    timeAgoText,
    streetName,
    areaName,
    recordedAt,
  );
}

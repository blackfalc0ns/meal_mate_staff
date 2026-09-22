import 'dispatcher_map_driver_status.dart';

class DispatcherMapDriverEntity {
  const DispatcherMapDriverEntity({
    required this.id,
    this.driverCode,
    required this.name,
    this.phoneNumber,
    this.plateNumber,
    this.avatarUrl,
    required this.boxId,
    this.tripId,
    this.latitude,
    this.longitude,
    this.heading,
    this.speed,
    this.lastLocationTimestamp,
    required this.status,
    this.statusText,
    this.statusColor,
    this.hasIssue = false,
    this.issueDescription,
    this.lastStatusTimestamp,
    this.locationZone,
    this.remainingDistanceKm,
    this.remainingDistanceText,
    this.remainingDeliveryValue,
  });

  final String id;
  final String? driverCode;
  final String name;
  final String? phoneNumber;
  final String? plateNumber;
  final String? avatarUrl;
  final String boxId;
  final String? tripId;
  final double? latitude;
  final double? longitude;
  final double? heading;
  final double? speed;
  final DateTime? lastLocationTimestamp;
  final DispatcherMapDriverStatus status;
  final String? statusText;
  final String? statusColor;
  final bool hasIssue;
  final String? issueDescription;
  final DateTime? lastStatusTimestamp;
  final String? locationZone;
  final double? remainingDistanceKm;
  final String? remainingDistanceText;
  final double? remainingDeliveryValue;

  bool get hasValidCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180 &&
      !(latitude == 0.0 && longitude == 0.0);

  String get locationName => locationZone ?? '';

  DispatcherMapDriverEntity copyWith({
    String? id,
    String? driverCode,
    String? name,
    String? phoneNumber,
    String? plateNumber,
    String? avatarUrl,
    String? boxId,
    String? tripId,
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    DateTime? lastLocationTimestamp,
    DispatcherMapDriverStatus? status,
    String? statusText,
    String? statusColor,
    bool? hasIssue,
    String? issueDescription,
    DateTime? lastStatusTimestamp,
    String? locationZone,
    double? remainingDistanceKm,
    String? remainingDistanceText,
    double? remainingDeliveryValue,
  }) {
    return DispatcherMapDriverEntity(
      id: id ?? this.id,
      driverCode: driverCode ?? this.driverCode,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      boxId: boxId ?? this.boxId,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      lastLocationTimestamp:
          lastLocationTimestamp ?? this.lastLocationTimestamp,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      statusColor: statusColor ?? this.statusColor,
      hasIssue: hasIssue ?? this.hasIssue,
      issueDescription: issueDescription ?? this.issueDescription,
      lastStatusTimestamp: lastStatusTimestamp ?? this.lastStatusTimestamp,
      locationZone: locationZone ?? this.locationZone,
      remainingDistanceKm: remainingDistanceKm ?? this.remainingDistanceKm,
      remainingDistanceText:
          remainingDistanceText ?? this.remainingDistanceText,
      remainingDeliveryValue:
          remainingDeliveryValue ?? this.remainingDeliveryValue,
    );
  }
}

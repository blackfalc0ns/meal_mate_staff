import 'dispatcher_map_driver_status.dart';
import 'dispatcher_map_kpi_entity.dart';

sealed class DispatcherMapRealtimeEvent {
  const DispatcherMapRealtimeEvent();
}

final class DriverLocationUpdated extends DispatcherMapRealtimeEvent {
  const DriverLocationUpdated({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.timestamp,
    this.locationZone,
    this.remainingDistanceKm,
    this.remainingDistanceText,
  });

  final String driverId;
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;
  final String? locationZone;
  final double? remainingDistanceKm;
  final String? remainingDistanceText;
}

final class DriverStatusUpdated extends DispatcherMapRealtimeEvent {
  const DriverStatusUpdated({
    required this.driverId,
    required this.status,
    this.statusText,
    this.statusColor,
    this.hasIssue,
    this.issueDescription,
    required this.timestamp,
    this.kpis,
  });

  final String driverId;
  final DispatcherMapDriverStatus status;
  final String? statusText;
  final String? statusColor;
  final bool? hasIssue;
  final String? issueDescription;
  final DateTime timestamp;
  final DispatcherMapKpiEntity? kpis;
}

final class DriverIssueUpdated extends DispatcherMapRealtimeEvent {
  const DriverIssueUpdated({
    required this.driverId,
    required this.hasIssue,
    this.issueDescription,
    required this.timestamp,
  });

  final String driverId;
  final bool hasIssue;
  final String? issueDescription;
  final DateTime timestamp;
}

final class DriverBoxAssigned extends DispatcherMapRealtimeEvent {
  const DriverBoxAssigned({
    this.boxId,
    this.driverId,
    this.tripId,
    this.timestamp,
  });

  final String? boxId;
  final String? driverId;
  final String? tripId;
  final DateTime? timestamp;
}

// Aliases for compatibility
typedef DispatcherMapLocationUpdatedEvent = DriverLocationUpdated;
typedef DispatcherMapStatusUpdatedEvent = DriverStatusUpdated;
typedef DispatcherMapIssueUpdatedEvent = DriverIssueUpdated;
typedef DispatcherMapBoxAssignedEvent = DriverBoxAssigned;

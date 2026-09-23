import '../../domain/entities/dispatcher_map_realtime_event.dart';
import '../models/realtime/dispatcher_box_assigned_event_dto.dart';
import '../models/realtime/dispatcher_driver_issue_event_dto.dart';
import '../models/realtime/dispatcher_driver_location_event_dto.dart';
import '../models/realtime/dispatcher_driver_status_event_dto.dart';
import '../realtime/dispatcher_map_realtime_event_dto.dart';
import 'dispatcher_map_mapper.dart';

DateTime _parseTimestamp(String? timestamp) {
  if (timestamp == null || timestamp.isEmpty) {
    return DateTime.now().toUtc();
  }
  return DateTime.tryParse(timestamp)?.toUtc() ?? DateTime.now().toUtc();
}

DateTime? _parseNullableTimestamp(String? timestamp) {
  if (timestamp == null || timestamp.isEmpty) return null;
  return DateTime.tryParse(timestamp)?.toUtc();
}

extension DispatcherDriverLocationEventDtoMapper
    on DispatcherDriverLocationEventDto {
  DriverLocationUpdated toDomain() {
    return DriverLocationUpdated(
      driverId: driverId ?? '',
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      heading: heading,
      speed: speed,
      timestamp: _parseTimestamp(timestamp),
      locationZone: locationZone,
      remainingDistanceKm: remainingDistanceKm,
      remainingDistanceText: remainingDistanceText,
    );
  }
}

extension DispatcherDriverStatusEventDtoMapper
    on DispatcherDriverStatusEventDto {
  DriverStatusUpdated toDomain() {
    return DriverStatusUpdated(
      driverId: driverId ?? '',
      status: status.toDriverStatus(),
      statusText: statusText,
      statusColor: statusColor,
      hasIssue: hasIssue,
      issueDescription: issueDescription,
      timestamp: _parseTimestamp(timestamp),
      kpis: kpis?.toEntity(),
      activeBoxesCount: activeBoxesCount,
    );
  }
}

extension DispatcherDriverIssueEventDtoMapper on DispatcherDriverIssueEventDto {
  DriverIssueUpdated toDomain() {
    return DriverIssueUpdated(
      driverId: driverId ?? '',
      hasIssue: hasIssue ?? false,
      issueDescription: issueDescription,
      timestamp: _parseTimestamp(timestamp),
    );
  }
}

extension DispatcherBoxAssignedEventDtoMapper on DispatcherBoxAssignedEventDto {
  DriverBoxAssigned toDomain() {
    return DriverBoxAssigned(
      boxId: boxId,
      boxCode: boxCode,
      driverId: driverId,
      tripId: tripId,
      timestamp: _parseNullableTimestamp(timestamp),
    );
  }
}

extension DispatcherMapRealtimeEventDtoMapper on DispatcherMapRealtimeEventDto {
  DispatcherMapRealtimeEvent toDomain() {
    return switch (this) {
      LocationUpdatedRealtimeDto(:final dto) => dto.toDomain(),
      StatusUpdatedRealtimeDto(:final dto) => dto.toDomain(),
      IssueUpdatedRealtimeDto(:final dto) => dto.toDomain(),
      BoxAssignedRealtimeDto(:final dto) => dto.toDomain(),
    };
  }
}

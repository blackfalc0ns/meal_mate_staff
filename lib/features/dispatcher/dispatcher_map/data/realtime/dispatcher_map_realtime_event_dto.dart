import '../models/realtime/dispatcher_box_assigned_event_dto.dart';
import '../models/realtime/dispatcher_driver_issue_event_dto.dart';
import '../models/realtime/dispatcher_driver_location_event_dto.dart';
import '../models/realtime/dispatcher_driver_status_event_dto.dart';

sealed class DispatcherMapRealtimeEventDto {
  const DispatcherMapRealtimeEventDto();
}

final class LocationUpdatedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const LocationUpdatedRealtimeDto(this.dto);
  final DispatcherDriverLocationEventDto dto;
}

final class StatusUpdatedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const StatusUpdatedRealtimeDto(this.dto);
  final DispatcherDriverStatusEventDto dto;
}

final class IssueUpdatedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const IssueUpdatedRealtimeDto(this.dto);
  final DispatcherDriverIssueEventDto dto;
}

final class BoxAssignedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const BoxAssignedRealtimeDto(this.dto);
  final DispatcherBoxAssignedEventDto dto;
}

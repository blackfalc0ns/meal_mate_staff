import 'dispatcher_box_assigned_event_dto.dart';
import 'dispatcher_driver_issue_event_dto.dart';
import 'dispatcher_driver_location_event_dto.dart';
import 'dispatcher_driver_status_event_dto.dart';

sealed class DispatcherMapRealtimeEventDto {
  const DispatcherMapRealtimeEventDto();
}

class LocationUpdatedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const LocationUpdatedRealtimeDto(this.dto);
  final DispatcherDriverLocationEventDto dto;
}

class StatusUpdatedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const StatusUpdatedRealtimeDto(this.dto);
  final DispatcherDriverStatusEventDto dto;
}

class IssueUpdatedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const IssueUpdatedRealtimeDto(this.dto);
  final DispatcherDriverIssueEventDto dto;
}

class BoxAssignedRealtimeDto extends DispatcherMapRealtimeEventDto {
  const BoxAssignedRealtimeDto(this.dto);
  final DispatcherBoxAssignedEventDto dto;
}

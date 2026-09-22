import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_box_assigned_event_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherBoxAssignedEventDto {
  const DispatcherBoxAssignedEventDto({
    this.boxId,
    this.driverId,
    this.tripId,
    this.timestamp,
  });

  final String? boxId;
  final String? driverId;
  final String? tripId;
  final String? timestamp;

  factory DispatcherBoxAssignedEventDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherBoxAssignedEventDtoFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_box_assigned_event_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherBoxAssignedEventDto {
  const DispatcherBoxAssignedEventDto({
    this.boxId,
    this.boxCode,
    this.driverId,
    this.tripId,
    this.timestamp,
  });

  final String? boxId;
  final String? boxCode;
  final String? driverId;
  final String? tripId;

  @JsonKey(readValue: _readAssignedAt)
  final String? timestamp;

  static Object? _readAssignedAt(Map json, String key) =>
      json['assignedAtUtc'] ?? json['timestamp'];

  factory DispatcherBoxAssignedEventDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherBoxAssignedEventDtoFromJson(json);
}

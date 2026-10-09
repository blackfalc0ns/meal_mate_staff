import 'package:json_annotation/json_annotation.dart';

part 'driver_reassignment_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DriverReassignmentRequestDto {
  const DriverReassignmentRequestDto({
    required this.reason,
    this.notes,
    this.latitude,
    this.longitude,
  });

  factory DriverReassignmentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverReassignmentRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverReassignmentRequestDtoToJson(this);

  final String reason;
  final String? notes;
  final double? latitude;
  final double? longitude;
}

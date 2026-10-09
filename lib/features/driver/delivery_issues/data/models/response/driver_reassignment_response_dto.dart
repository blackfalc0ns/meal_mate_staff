import 'package:json_annotation/json_annotation.dart';

part 'driver_reassignment_response_dto.g.dart';

@JsonSerializable()
class DriverReassignmentResponseDto {
  const DriverReassignmentResponseDto({
    this.requestId,
    this.boxId,
    this.boxCode,
    this.status,
    this.message,
    this.requestedAtUtc,
  });

  factory DriverReassignmentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverReassignmentResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverReassignmentResponseDtoToJson(this);

  final String? requestId;
  final String? boxId;
  final String? boxCode;
  final String? status;
  final String? message;
  final String? requestedAtUtc;
}

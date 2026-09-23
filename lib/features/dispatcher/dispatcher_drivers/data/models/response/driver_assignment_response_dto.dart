import 'package:json_annotation/json_annotation.dart';

part 'driver_assignment_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverAssignmentResponseDto {
  const DriverAssignmentResponseDto({
    this.success,
    this.message,
    this.assignedAt,
    this.boxId,
    this.driverId,
  });

  factory DriverAssignmentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverAssignmentResponseDtoFromJson(json);

  final bool? success;
  final String? message;
  final String? assignedAt;
  final String? boxId;
  final String? driverId;
}

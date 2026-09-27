import 'package:json_annotation/json_annotation.dart';

part 'update_driver_availability_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class UpdateDriverAvailabilityResponseDto {
  const UpdateDriverAvailabilityResponseDto({
    this.driverId,
    this.isAvailable,
    this.operationalStatus,
    this.updatedAtUtc,
  });

  factory UpdateDriverAvailabilityResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateDriverAvailabilityResponseDtoFromJson(json);

  final String? driverId;
  final bool? isAvailable;
  final String? operationalStatus;
  final String? updatedAtUtc;
}

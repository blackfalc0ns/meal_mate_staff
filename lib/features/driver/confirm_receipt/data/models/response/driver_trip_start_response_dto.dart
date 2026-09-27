import 'package:json_annotation/json_annotation.dart';

part 'driver_trip_start_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverTripStartResponseDto {
  const DriverTripStartResponseDto({
    this.tripId,
    this.tripCode,
    this.startedAtUtc,
    this.status,
    this.statusText,
    this.activeRouteId,
    this.message,
  });

  factory DriverTripStartResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverTripStartResponseDtoFromJson(json);

  final String? tripId;
  final String? tripCode;
  final String? startedAtUtc;
  final String? status;
  final String? statusText;
  final String? activeRouteId;
  final String? message;
}

import 'package:json_annotation/json_annotation.dart';

import 'driver_map_location_response_dto.dart';

part 'driver_map_navigation_response_dto.g.dart';

@JsonSerializable()
class DriverMapNavigationResponseDto {
  const DriverMapNavigationResponseDto({
    this.destinationStopId,
    this.origin,
    this.destination,
    this.routeStatus,
    this.unavailableReason,
    this.encodedPolyline,
    this.polylineEncoding,
    this.distanceMeters,
    this.durationSeconds,
    this.estimatedArrivalAtUtc,
    this.calculatedAtUtc,
    this.googleMapsUrl,
    this.canNavigate,
  });

  factory DriverMapNavigationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverMapNavigationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverMapNavigationResponseDtoToJson(this);

  final String? destinationStopId;
  final DriverMapLocationResponseDto? origin;
  final DriverMapLocationResponseDto? destination;
  final String? routeStatus;
  final String? unavailableReason;
  final String? encodedPolyline;
  final String? polylineEncoding;
  final int? distanceMeters;
  final int? durationSeconds;
  final String? estimatedArrivalAtUtc;
  final String? calculatedAtUtc;
  final String? googleMapsUrl;
  final bool? canNavigate;
}

import 'package:json_annotation/json_annotation.dart';

part 'driver_current_location_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverCurrentLocationResponseDto {
  const DriverCurrentLocationResponseDto({
    this.latitude,
    this.longitude,
    this.heading,
    this.speed,
    this.destinationLatitude,
    this.destinationLongitude,
    this.statusBadgeText,
    this.timeAgoText,
    this.streetName,
    this.areaName,
    this.routePolyline,
    this.recordedAt,
  });

  factory DriverCurrentLocationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverCurrentLocationResponseDtoFromJson(json);

  final num? latitude;
  final num? longitude;
  final num? heading;
  final num? speed;
  final num? destinationLatitude;
  final num? destinationLongitude;
  final String? statusBadgeText;
  final String? timeAgoText;
  final String? streetName;
  final String? areaName;
  final String? routePolyline;
  final String? recordedAt;
}

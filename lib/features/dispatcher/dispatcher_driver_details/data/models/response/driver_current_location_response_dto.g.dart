// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_current_location_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverCurrentLocationResponseDto _$DriverCurrentLocationResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverCurrentLocationResponseDto(
  latitude: json['latitude'] as num?,
  longitude: json['longitude'] as num?,
  heading: json['heading'] as num?,
  speed: json['speed'] as num?,
  destinationLatitude: json['destinationLatitude'] as num?,
  destinationLongitude: json['destinationLongitude'] as num?,
  statusBadgeText: json['statusBadgeText'] as String?,
  timeAgoText: json['timeAgoText'] as String?,
  streetName: json['streetName'] as String?,
  areaName: json['areaName'] as String?,
  routePolyline: json['routePolyline'] as String?,
  recordedAt: json['recordedAt'] as String?,
);

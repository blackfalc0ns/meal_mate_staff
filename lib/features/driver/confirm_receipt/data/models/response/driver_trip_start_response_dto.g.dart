// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_trip_start_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverTripStartResponseDto _$DriverTripStartResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverTripStartResponseDto(
  tripId: json['tripId'] as String?,
  tripCode: json['tripCode'] as String?,
  startedAtUtc: json['startedAtUtc'] as String?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  activeRouteId: json['activeRouteId'] as String?,
  message: json['message'] as String?,
);

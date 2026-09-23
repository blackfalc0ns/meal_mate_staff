// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_driver_location_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherDriverLocationEventDto _$DispatcherDriverLocationEventDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverLocationEventDto(
  driverId: json['driverId'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  speed: (DispatcherDriverLocationEventDto._readSpeed(json, 'speed') as num?)
      ?.toDouble(),
  timestamp:
      DispatcherDriverLocationEventDto._readRecordedAt(json, 'timestamp')
          as String?,
  locationZone: json['locationZone'] as String?,
  remainingDistanceKm: (json['remainingDistanceKm'] as num?)?.toDouble(),
  remainingDistanceText: json['remainingDistanceText'] as String?,
);

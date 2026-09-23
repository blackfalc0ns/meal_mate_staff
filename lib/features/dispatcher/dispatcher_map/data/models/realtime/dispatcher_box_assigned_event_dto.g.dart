// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_box_assigned_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherBoxAssignedEventDto _$DispatcherBoxAssignedEventDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherBoxAssignedEventDto(
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  driverId: json['driverId'] as String?,
  tripId: json['tripId'] as String?,
  timestamp:
      DispatcherBoxAssignedEventDto._readAssignedAt(json, 'timestamp')
          as String?,
);

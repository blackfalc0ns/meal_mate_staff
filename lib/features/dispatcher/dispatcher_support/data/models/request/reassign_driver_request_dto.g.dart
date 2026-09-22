// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reassign_driver_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReassignDriverRequestDto _$ReassignDriverRequestDtoFromJson(
  Map<String, dynamic> json,
) => ReassignDriverRequestDto(
  replacementDriverId: json['replacementDriverId'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ReassignDriverRequestDtoToJson(
  ReassignDriverRequestDto instance,
) => <String, dynamic>{
  'replacementDriverId': instance.replacementDriverId,
  'notes': ?instance.notes,
};

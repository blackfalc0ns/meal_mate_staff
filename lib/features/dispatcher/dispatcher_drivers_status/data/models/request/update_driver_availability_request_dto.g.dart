// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_driver_availability_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDriverAvailabilityRequestDto _$UpdateDriverAvailabilityRequestDtoFromJson(
  Map<String, dynamic> json,
) => UpdateDriverAvailabilityRequestDto(
  isAvailable: UpdateDriverAvailabilityRequestDto._statusFromJson(
    json['shiftStatus'] as String,
  ),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$UpdateDriverAvailabilityRequestDtoToJson(
  UpdateDriverAvailabilityRequestDto instance,
) => <String, dynamic>{
  'shiftStatus': UpdateDriverAvailabilityRequestDto._statusToJson(
    instance.isAvailable,
  ),
};

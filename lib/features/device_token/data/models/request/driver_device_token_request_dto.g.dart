// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_device_token_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverDeviceTokenRequestDto _$DriverDeviceTokenRequestDtoFromJson(
  Map<String, dynamic> json,
) => DriverDeviceTokenRequestDto(
  token: json['token'] as String,
  platform: json['platform'] as String,
  deviceId: json['deviceId'] as String,
  registrationId: json['registrationId'] as String?,
);

Map<String, dynamic> _$DriverDeviceTokenRequestDtoToJson(
  DriverDeviceTokenRequestDto instance,
) => <String, dynamic>{
  'token': instance.token,
  'platform': instance.platform,
  'deviceId': instance.deviceId,
  'registrationId': ?instance.registrationId,
};

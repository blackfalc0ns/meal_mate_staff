// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_device_token_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantDeviceTokenRequestDto _$RestaurantDeviceTokenRequestDtoFromJson(
  Map<String, dynamic> json,
) => RestaurantDeviceTokenRequestDto(
  token: json['token'] as String,
  platform: json['platform'] as String,
  deviceId: json['deviceId'] as String,
);

Map<String, dynamic> _$RestaurantDeviceTokenRequestDtoToJson(
  RestaurantDeviceTokenRequestDto instance,
) => <String, dynamic>{
  'token': instance.token,
  'platform': instance.platform,
  'deviceId': instance.deviceId,
};

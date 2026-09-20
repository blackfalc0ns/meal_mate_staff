// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_registration_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverRegistrationResponseDto _$DriverRegistrationResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverRegistrationResponseDto(
  registrationId: json['registrationId'] as String?,
  restaurantId: json['restaurantId'] as String?,
  restaurantName: json['restaurantName'] as String?,
  phone: json['phone'] as String?,
  status: json['status'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$DriverRegistrationResponseDtoToJson(
  DriverRegistrationResponseDto instance,
) => <String, dynamic>{
  'registrationId': instance.registrationId,
  'restaurantId': instance.restaurantId,
  'restaurantName': instance.restaurantName,
  'phone': instance.phone,
  'status': instance.status,
  'message': instance.message,
};

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
  fullName: json['fullName'] as String?,
  fullNameAr: json['fullNameAr'] as String?,
  fullNameEn: json['fullNameEn'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  status: json['status'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$DriverRegistrationResponseDtoToJson(
  DriverRegistrationResponseDto instance,
) => <String, dynamic>{
  'registrationId': instance.registrationId,
  'restaurantId': instance.restaurantId,
  'restaurantName': instance.restaurantName,
  'fullName': instance.fullName,
  'fullNameAr': instance.fullNameAr,
  'fullNameEn': instance.fullNameEn,
  'phone': instance.phone,
  'email': instance.email,
  'status': instance.status,
  'message': instance.message,
};

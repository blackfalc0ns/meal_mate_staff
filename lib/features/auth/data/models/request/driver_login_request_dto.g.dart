// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_login_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverLoginRequestDto _$DriverLoginRequestDtoFromJson(
  Map<String, dynamic> json,
) => DriverLoginRequestDto(
  phone: json['phone'] as String,
  password: json['password'] as String,
  email: json['email'] as String?,
);

Map<String, dynamic> _$DriverLoginRequestDtoToJson(
  DriverLoginRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'password': instance.password,
  'email': ?instance.email,
};

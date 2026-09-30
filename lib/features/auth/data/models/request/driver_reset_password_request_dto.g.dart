// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_reset_password_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverResetPasswordRequestDto _$DriverResetPasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => DriverResetPasswordRequestDto(
  phone: json['phone'] as String,
  otpCode: json['otpCode'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$DriverResetPasswordRequestDtoToJson(
  DriverResetPasswordRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'otpCode': instance.otpCode,
  'newPassword': instance.newPassword,
};

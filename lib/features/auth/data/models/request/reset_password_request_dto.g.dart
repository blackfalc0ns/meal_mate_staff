// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetPasswordRequestDto _$ResetPasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequestDto(
  phone: json['phone'] as String,
  role: json['role'] as String,
  otpCode: json['otpCode'] as String,
  newPassword: json['newPassword'] as String,
  confirmPassword: json['confirmPassword'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestDtoToJson(
  ResetPasswordRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'role': instance.role,
  'otpCode': instance.otpCode,
  'newPassword': instance.newPassword,
  'confirmPassword': instance.confirmPassword,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetPasswordRequestDto _$SetPasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => SetPasswordRequestDto(
  phone: json['phone'] as String,
  role: json['role'] as String,
  verificationToken: json['verificationToken'] as String,
  newPassword: json['newPassword'] as String,
  confirmPassword: json['confirmPassword'] as String,
);

Map<String, dynamic> _$SetPasswordRequestDtoToJson(
  SetPasswordRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'role': instance.role,
  'verificationToken': instance.verificationToken,
  'newPassword': instance.newPassword,
  'confirmPassword': instance.confirmPassword,
};

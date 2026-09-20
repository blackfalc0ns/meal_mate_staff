// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_login_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffLoginRequestDto _$StaffLoginRequestDtoFromJson(
  Map<String, dynamic> json,
) => StaffLoginRequestDto(
  phone: json['phone'] as String,
  role: json['role'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$StaffLoginRequestDtoToJson(
  StaffLoginRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'role': instance.role,
  'password': instance.password,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_first_time_otp_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyFirstTimeOtpRequestDto _$VerifyFirstTimeOtpRequestDtoFromJson(
  Map<String, dynamic> json,
) => VerifyFirstTimeOtpRequestDto(
  phone: json['phone'] as String,
  role: json['role'] as String,
  otpCode: json['otpCode'] as String,
);

Map<String, dynamic> _$VerifyFirstTimeOtpRequestDtoToJson(
  VerifyFirstTimeOtpRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'role': instance.role,
  'otpCode': instance.otpCode,
};

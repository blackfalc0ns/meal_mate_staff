// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_first_time_otp_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyFirstTimeOtpResponseDto _$VerifyFirstTimeOtpResponseDtoFromJson(
  Map<String, dynamic> json,
) => VerifyFirstTimeOtpResponseDto(
  verified: json['verified'] as bool?,
  verificationToken: json['verificationToken'] as String?,
  phone: json['phone'] as String?,
  role: json['role'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$VerifyFirstTimeOtpResponseDtoToJson(
  VerifyFirstTimeOtpResponseDto instance,
) => <String, dynamic>{
  'verified': instance.verified,
  'verificationToken': instance.verificationToken,
  'phone': instance.phone,
  'role': instance.role,
  'message': instance.message,
};

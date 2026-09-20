// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resend_otp_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResendOtpRequestDto _$ResendOtpRequestDtoFromJson(Map<String, dynamic> json) =>
    ResendOtpRequestDto(
      phone: json['phone'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$ResendOtpRequestDtoToJson(
  ResendOtpRequestDto instance,
) => <String, dynamic>{'phone': instance.phone, 'role': instance.role};

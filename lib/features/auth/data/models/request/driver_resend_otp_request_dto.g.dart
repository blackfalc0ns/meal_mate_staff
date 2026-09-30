// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_resend_otp_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverResendOtpRequestDto _$DriverResendOtpRequestDtoFromJson(
  Map<String, dynamic> json,
) => DriverResendOtpRequestDto(
  destination: json['destination'] as String,
  channel: json['channel'] as String? ?? 'Phone',
  purpose: json['purpose'] as String? ?? 'VerifyPhone',
);

Map<String, dynamic> _$DriverResendOtpRequestDtoToJson(
  DriverResendOtpRequestDto instance,
) => <String, dynamic>{
  'destination': instance.destination,
  'channel': instance.channel,
  'purpose': instance.purpose,
};

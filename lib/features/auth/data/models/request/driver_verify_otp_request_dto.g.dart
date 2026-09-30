// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_verify_otp_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverVerifyOtpRequestDto _$DriverVerifyOtpRequestDtoFromJson(
  Map<String, dynamic> json,
) => DriverVerifyOtpRequestDto(
  destination: json['destination'] as String,
  purpose: json['purpose'] as String? ?? 'VerifyPhone',
  code: json['code'] as String,
);

Map<String, dynamic> _$DriverVerifyOtpRequestDtoToJson(
  DriverVerifyOtpRequestDto instance,
) => <String, dynamic>{
  'destination': instance.destination,
  'purpose': instance.purpose,
  'code': instance.code,
};

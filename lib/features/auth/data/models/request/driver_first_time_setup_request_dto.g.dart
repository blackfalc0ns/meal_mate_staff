// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_first_time_setup_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverFirstTimeSetupRequestDto _$DriverFirstTimeSetupRequestDtoFromJson(
  Map<String, dynamic> json,
) => DriverFirstTimeSetupRequestDto(
  phone: json['phone'] as String,
  otpCode: json['otpCode'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$DriverFirstTimeSetupRequestDtoToJson(
  DriverFirstTimeSetupRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'otpCode': instance.otpCode,
  'password': instance.password,
};

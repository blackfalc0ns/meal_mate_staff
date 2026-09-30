// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_message_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverMessageResponseDto _$DriverMessageResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverMessageResponseDto(
  message: json['message'] as String?,
  success: json['success'] as bool?,
);

Map<String, dynamic> _$DriverMessageResponseDtoToJson(
  DriverMessageResponseDto instance,
) => <String, dynamic>{
  'message': instance.message,
  'success': instance.success,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_message_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffMessageResponseDto _$StaffMessageResponseDtoFromJson(
  Map<String, dynamic> json,
) => StaffMessageResponseDto(
  success: json['success'] as bool?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$StaffMessageResponseDtoToJson(
  StaffMessageResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

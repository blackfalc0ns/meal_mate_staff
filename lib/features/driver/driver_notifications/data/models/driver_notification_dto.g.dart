// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverNotificationDto _$DriverNotificationDtoFromJson(
  Map<String, dynamic> json,
) => DriverNotificationDto(
  id: json['id'] as String?,
  title: json['title'] as String?,
  body: json['body'] as String?,
  message: json['message'] as String?,
  type: json['type'] as String?,
  category: json['category'] as String?,
  isRead: json['isRead'] as bool?,
  createdAtUtc: json['createdAtUtc'] as String?,
  createdAt: json['createdAt'] as String?,
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DriverNotificationDtoToJson(
  DriverNotificationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'message': instance.message,
  'type': instance.type,
  'category': instance.category,
  'isRead': instance.isRead,
  'createdAtUtc': instance.createdAtUtc,
  'createdAt': instance.createdAt,
  'data': instance.data,
};

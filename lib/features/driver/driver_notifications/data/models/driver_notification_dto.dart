import 'package:json_annotation/json_annotation.dart';

part 'driver_notification_dto.g.dart';

@JsonSerializable()
class DriverNotificationDto {
  const DriverNotificationDto({
    this.id,
    this.title,
    this.body,
    this.message,
    this.type,
    this.category,
    this.isRead,
    this.createdAtUtc,
    this.createdAt,
    this.data,
  });

  factory DriverNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$DriverNotificationDtoFromJson(json);

  final String? id;
  final String? title;
  final String? body;
  final String? message;
  final String? type;
  final String? category;
  final bool? isRead;
  final String? createdAtUtc;
  final String? createdAt;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => _$DriverNotificationDtoToJson(this);
}

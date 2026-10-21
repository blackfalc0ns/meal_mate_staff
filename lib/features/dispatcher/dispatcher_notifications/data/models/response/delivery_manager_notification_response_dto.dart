import 'package:json_annotation/json_annotation.dart';

part 'delivery_manager_notification_response_dto.g.dart';

@JsonSerializable()
class DeliveryManagerNotificationResponseDto {
  const DeliveryManagerNotificationResponseDto({
    this.notificationId,
    this.type,
    this.title,
    this.body,
    this.sentTimeAgo,
    this.isRead,
    this.section,
    this.subjectId,
    this.deepLink,
    this.sentAtUtc,
  });

  factory DeliveryManagerNotificationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DeliveryManagerNotificationResponseDtoFromJson(json);

  final String? notificationId;
  final String? type;
  final String? title;
  final String? body;
  final String? sentTimeAgo;
  final bool? isRead;
  final String? section;
  final String? subjectId;
  final String? deepLink;
  final DateTime? sentAtUtc;

  Map<String, dynamic> toJson() =>
      _$DeliveryManagerNotificationResponseDtoToJson(this);
}

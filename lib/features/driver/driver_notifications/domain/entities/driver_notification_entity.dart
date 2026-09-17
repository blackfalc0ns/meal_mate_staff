import 'driver_notification_filter_type.dart';
import 'driver_notification_type.dart';

class DriverNotificationEntity {
  const DriverNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.filterCategory,
    this.isRead = true,
    this.isToday = true,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final DriverNotificationType type;
  final DriverNotificationFilterType filterCategory;
  final bool isRead;
  final bool isToday;

  DriverNotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? time,
    DriverNotificationType? type,
    DriverNotificationFilterType? filterCategory,
    bool? isRead,
    bool? isToday,
  }) {
    return DriverNotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      type: type ?? this.type,
      filterCategory: filterCategory ?? this.filterCategory,
      isRead: isRead ?? this.isRead,
      isToday: isToday ?? this.isToday,
    );
  }
}

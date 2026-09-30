import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/entities/driver_notification_filter_type.dart';
import '../../domain/entities/driver_notification_type.dart';
import '../models/driver_notification_dto.dart';

extension DriverNotificationDtoMapper on DriverNotificationDto {
  DriverNotificationEntity toEntity() {
    final parsedTime = _parseDateTime(createdAtUtc ?? createdAt);
    final isToday = _checkIsToday(parsedTime);
    final formattedTime = _formatTime(parsedTime);

    final mappedType = _mapNotificationType(type);
    final mappedCategory = _mapFilterCategory(category, mappedType);

    return DriverNotificationEntity(
      id: id ?? '',
      title: title ?? '',
      body: body ?? message ?? '',
      time: formattedTime,
      type: mappedType,
      filterCategory: mappedCategory,
      isRead: isRead ?? false,
      isToday: isToday,
    );
  }

  static DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final parsed = DateTime.parse(raw.trim());
      return parsed.isUtc ? parsed.toLocal() : parsed;
    } catch (_) {
      return null;
    }
  }

  static bool _checkIsToday(DateTime? dateTime) {
    if (dateTime == null) return true;
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isPm ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  static DriverNotificationType _mapNotificationType(String? rawType) {
    final lower = (rawType ?? '').toLowerCase();
    if (lower.contains('new_order') || lower.contains('neworder')) {
      return DriverNotificationType.newOrder;
    }
    if (lower.contains('delivered')) {
      return DriverNotificationType.delivered;
    }
    if (lower.contains('earning')) {
      return DriverNotificationType.earnings;
    }
    if (lower.contains('rating')) {
      return DriverNotificationType.rating;
    }
    if (lower.contains('offer')) {
      return DriverNotificationType.offer;
    }
    return DriverNotificationType.system;
  }

  static DriverNotificationFilterType _mapFilterCategory(
    String? rawCategory,
    DriverNotificationType resolvedType,
  ) {
    final lower = (rawCategory ?? '').toLowerCase();
    if (lower.contains('delivery') || lower.contains('order')) {
      return DriverNotificationFilterType.deliveryOrders;
    }
    if (lower.contains('offer')) {
      return DriverNotificationFilterType.offers;
    }
    if (lower.contains('system')) {
      return DriverNotificationFilterType.system;
    }

    switch (resolvedType) {
      case DriverNotificationType.newOrder:
      case DriverNotificationType.delivered:
        return DriverNotificationFilterType.deliveryOrders;
      case DriverNotificationType.offer:
        return DriverNotificationFilterType.offers;
      case DriverNotificationType.earnings:
      case DriverNotificationType.rating:
      case DriverNotificationType.system:
        return DriverNotificationFilterType.system;
    }
  }
}

extension DriverNotificationDtoListMapper on List<DriverNotificationDto> {
  List<DriverNotificationEntity> toEntityList() {
    return map((dto) => dto.toEntity()).toList();
  }
}

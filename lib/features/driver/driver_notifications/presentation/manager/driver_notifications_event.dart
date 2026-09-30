import '../../domain/entities/driver_notification_filter_type.dart';

sealed class DriverNotificationsEvent {
  const DriverNotificationsEvent();
}

class DriverNotificationsLoadEvent extends DriverNotificationsEvent {
  const DriverNotificationsLoadEvent();
}

class DriverNotificationsRefreshEvent extends DriverNotificationsEvent {
  const DriverNotificationsRefreshEvent();
}

class DriverNotificationsFilterChangedEvent extends DriverNotificationsEvent {
  const DriverNotificationsFilterChangedEvent(this.filter);

  final DriverNotificationFilterType filter;
}

class DriverNotificationsMarkReadEvent extends DriverNotificationsEvent {
  const DriverNotificationsMarkReadEvent(this.notificationId);

  final String notificationId;
}

class DriverNotificationsMarkAllReadEvent extends DriverNotificationsEvent {
  const DriverNotificationsMarkAllReadEvent();
}

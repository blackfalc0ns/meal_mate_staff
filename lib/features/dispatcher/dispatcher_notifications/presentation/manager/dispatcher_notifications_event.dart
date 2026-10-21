import '../../domain/entities/dispatcher_notification_entity.dart';
import '../../domain/entities/dispatcher_notification_filter_type.dart';

abstract class DispatcherNotificationsEvent {
  const DispatcherNotificationsEvent();
}

class LoadDispatcherNotificationsEvent extends DispatcherNotificationsEvent {
  const LoadDispatcherNotificationsEvent({this.isRefresh = false});

  final bool isRefresh;
}

class MarkDispatcherNotificationReadEvent extends DispatcherNotificationsEvent {
  const MarkDispatcherNotificationReadEvent(this.notificationId);

  final String notificationId;
}

class MarkAllLoadedDispatcherNotificationsReadEvent
    extends DispatcherNotificationsEvent {
  const MarkAllLoadedDispatcherNotificationsReadEvent();
}

class ChangeDispatcherNotificationsFilterEvent
    extends DispatcherNotificationsEvent {
  const ChangeDispatcherNotificationsFilterEvent(this.filter);

  final DispatcherNotificationFilterType filter;
}

class OnNotificationItemTappedEvent extends DispatcherNotificationsEvent {
  const OnNotificationItemTappedEvent(this.notification);

  final DispatcherNotificationEntity notification;
}

class ClearDispatcherNotificationsEvent extends DispatcherNotificationsEvent {
  const ClearDispatcherNotificationsEvent();
}

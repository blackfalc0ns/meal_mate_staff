import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../../domain/entities/dispatcher_map_realtime_event.dart';

sealed class DispatcherMapEvent {
  const DispatcherMapEvent();
}

class LoadDispatcherMapEvent extends DispatcherMapEvent {
  const LoadDispatcherMapEvent({this.restaurantId, this.status});
  final String? restaurantId;
  final String? status;
}

class RefreshDispatcherMapEvent extends DispatcherMapEvent {
  const RefreshDispatcherMapEvent();
}

class RetryDispatcherMapEvent extends DispatcherMapEvent {
  const RetryDispatcherMapEvent();
}

class RetryDispatcherMapRealtimeEvent extends DispatcherMapEvent {
  const RetryDispatcherMapRealtimeEvent();
}

class SelectDriverDispatcherMapEvent extends DispatcherMapEvent {
  const SelectDriverDispatcherMapEvent(this.driverId);
  final String driverId;
}

class TabActiveStateChangedEvent extends DispatcherMapEvent {
  const TabActiveStateChangedEvent({required this.isActive});
  final bool isActive;
}

class DispatcherMapTabActivatedEvent extends DispatcherMapEvent {
  const DispatcherMapTabActivatedEvent();
}

class DispatcherMapTabDeactivatedEvent extends DispatcherMapEvent {
  const DispatcherMapTabDeactivatedEvent();
}

class AppLifecycleStateChangedEvent extends DispatcherMapEvent {
  const AppLifecycleStateChangedEvent({required this.isResumed});
  final bool isResumed;
}

class DispatcherMapAppResumedEvent extends DispatcherMapEvent {
  const DispatcherMapAppResumedEvent();
}

class DispatcherMapAppPausedEvent extends DispatcherMapEvent {
  const DispatcherMapAppPausedEvent();
}

typedef SelectDispatcherMapDriverEvent = SelectDriverDispatcherMapEvent;

class RealtimeEventReceived extends DispatcherMapEvent {
  const RealtimeEventReceived(this.event);
  final DispatcherMapRealtimeEvent event;
}

class RealtimeConnectionStatusReceived extends DispatcherMapEvent {
  const RealtimeConnectionStatusReceived(this.status);
  final DispatcherMapConnectionStatus status;
}

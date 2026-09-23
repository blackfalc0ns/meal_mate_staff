import '../../../dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import '../../../dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';

sealed class DriverDetailsEvent {
  const DriverDetailsEvent();
}

class LoadDriverDetailsEvent extends DriverDetailsEvent {
  const LoadDriverDetailsEvent();
}

class RefreshDriverDetailsEvent extends DriverDetailsEvent {
  const RefreshDriverDetailsEvent();
}

class RetryDriverProfileEvent extends DriverDetailsEvent {
  const RetryDriverProfileEvent();
}

class RetryDriverBoxesEvent extends DriverDetailsEvent {
  const RetryDriverBoxesEvent();
}

class RetryDriverLocationEvent extends DriverDetailsEvent {
  const RetryDriverLocationEvent();
}

class RealtimeDriverDetailsEventReceived extends DriverDetailsEvent {
  const RealtimeDriverDetailsEventReceived(this.event);
  final DispatcherMapRealtimeEvent event;
}

class DriverDetailsConnectionStatusReceived extends DriverDetailsEvent {
  const DriverDetailsConnectionStatusReceived(this.status);
  final DispatcherMapConnectionStatus status;
}

class DriverDetailsLifecycleResumed extends DriverDetailsEvent {
  const DriverDetailsLifecycleResumed();
}

class DriverDetailsLifecyclePaused extends DriverDetailsEvent {
  const DriverDetailsLifecyclePaused();
}

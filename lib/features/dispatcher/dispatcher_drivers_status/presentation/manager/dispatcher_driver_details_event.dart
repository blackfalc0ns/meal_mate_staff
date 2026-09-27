import '../../domain/entities/update_driver_availability_result_entity.dart';

sealed class DispatcherDriverDetailsEvent {
  const DispatcherDriverDetailsEvent();
}

final class Started extends DispatcherDriverDetailsEvent {
  const Started(this.driverId);
  final String driverId;
}

final class Refreshed extends DispatcherDriverDetailsEvent {
  const Refreshed();
}

final class AvailabilityChanged extends DispatcherDriverDetailsEvent {
  const AvailabilityChanged(this.isAvailable, {this.reason});
  final bool isAvailable;
  final String? reason;
}

final class RealtimeAvailabilityReceived extends DispatcherDriverDetailsEvent {
  const RealtimeAvailabilityReceived(this.update);
  final UpdateDriverAvailabilityResultEntity update;
}

final class RetryRequested extends DispatcherDriverDetailsEvent {
  const RetryRequested();
}

final class ClearInlineFailure extends DispatcherDriverDetailsEvent {
  const ClearInlineFailure();
}

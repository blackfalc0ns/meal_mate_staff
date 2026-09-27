sealed class DriverPickupSummaryEvent {
  const DriverPickupSummaryEvent();
}

final class LoadDriverPickupSummaryEvent extends DriverPickupSummaryEvent {
  const LoadDriverPickupSummaryEvent(this.tripId);
  final String tripId;
}

final class RetryDriverPickupSummaryEvent extends DriverPickupSummaryEvent {
  const RetryDriverPickupSummaryEvent();
}

final class StartDriverTripEvent extends DriverPickupSummaryEvent {
  const StartDriverTripEvent();
}

sealed class DriverOrdersRealtimeEvent {
  const DriverOrdersRealtimeEvent({
    required this.eventId,
    required this.occurredAtUtc,
  });

  final String eventId;
  final DateTime occurredAtUtc;
}

class DriverOrderDeliveredEvent extends DriverOrdersRealtimeEvent {
  const DriverOrderDeliveredEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.tripId,
    required this.boxId,
    required this.tripStopId,
    this.statusText,
    this.deliveredAtUtc,
  });

  final String tripId;
  final String boxId;
  final String tripStopId;
  final String? statusText;
  final DateTime? deliveredAtUtc;
}

class DriverDeliveryFailedEvent extends DriverOrdersRealtimeEvent {
  const DriverDeliveryFailedEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.tripId,
    required this.boxId,
    required this.tripStopId,
    this.statusText,
    this.failureReasonCategory,
    this.failureReasonText,
  });

  final String tripId;
  final String boxId;
  final String tripStopId;
  final String? statusText;
  final String? failureReasonCategory;
  final String? failureReasonText;
}

class DriverArrivedAtCustomerEvent extends DriverOrdersRealtimeEvent {
  const DriverArrivedAtCustomerEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.tripId,
    required this.boxId,
    required this.tripStopId,
    this.statusText,
  });

  final String tripId;
  final String boxId;
  final String tripStopId;
  final String? statusText;
}

class DriverReassignmentRequestedEvent extends DriverOrdersRealtimeEvent {
  const DriverReassignmentRequestedEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.tripId,
    required this.boxId,
    required this.tripStopId,
    this.statusText,
    this.failureReasonCategory,
    this.failureReasonText,
  });

  final String tripId;
  final String boxId;
  final String tripStopId;
  final String? statusText;
  final String? failureReasonCategory;
  final String? failureReasonText;
}

class DriverTripInTransitEvent extends DriverOrdersRealtimeEvent {
  const DriverTripInTransitEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.tripId,
    this.tripStatusText,
  });

  final String tripId;
  final String? tripStatusText;
}

class DriverUnknownRealtimeEvent extends DriverOrdersRealtimeEvent {
  const DriverUnknownRealtimeEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.eventType,
  });

  final String eventType;
}

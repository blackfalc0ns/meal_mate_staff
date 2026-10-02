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

class DriverBoxAssignedEvent extends DriverOrdersRealtimeEvent {
  const DriverBoxAssignedEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.boxId,
    this.boxCode,
    this.tripId,
    this.isReassigned = false,
  });

  final String boxId;
  final String? boxCode;
  final String? tripId;
  final bool isReassigned;
}

class DriverDeliveryCompletedEvent extends DriverOrdersRealtimeEvent {
  const DriverDeliveryCompletedEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.boxId,
    this.tripId,
    this.remainingBoxesCount,
  });

  final String boxId;
  final String? tripId;
  final int? remainingBoxesCount;
}

class DriverKitchenReadyEvent extends DriverOrdersRealtimeEvent {
  const DriverKitchenReadyEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.boxId,
    this.mealName,
  });

  final String boxId;
  final String? mealName;
}

class DriverShiftStatusConfirmedEvent extends DriverOrdersRealtimeEvent {
  const DriverShiftStatusConfirmedEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.status,
  });

  final String status;
}

class DriverDispatcherMessageEvent extends DriverOrdersRealtimeEvent {
  const DriverDispatcherMessageEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.message,
    this.title,
  });

  final String message;
  final String? title;
}

class DriverConnectionEstablishedEvent extends DriverOrdersRealtimeEvent {
  const DriverConnectionEstablishedEvent({
    required super.eventId,
    required super.occurredAtUtc,
    this.connectionId,
  });

  final String? connectionId;
}

class DriverTrackingNotRequiredEvent extends DriverOrdersRealtimeEvent {
  const DriverTrackingNotRequiredEvent({
    required super.eventId,
    required super.occurredAtUtc,
    this.reason,
  });

  final String? reason;
}

class DriverUnknownRealtimeEvent extends DriverOrdersRealtimeEvent {
  const DriverUnknownRealtimeEvent({
    required super.eventId,
    required super.occurredAtUtc,
    required this.eventType,
  });

  final String eventType;
}

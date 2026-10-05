import '../../../domain/entities/driver_orders_realtime_event.dart';

class DriverOrdersRealtimeEventDto {
  static DriverOrdersRealtimeEvent fromPayload(
    String eventType,
    Map<String, dynamic> json,
  ) {
    final eventId = (json['eventId'] ?? '').toString();
    DateTime occurredAtUtc;
    if (json['occurredAtUtc'] != null) {
      occurredAtUtc =
          DateTime.tryParse(json['occurredAtUtc'].toString())?.toUtc() ??
          DateTime.now().toUtc();
    } else {
      occurredAtUtc = DateTime.now().toUtc();
    }

    final tripId = (json['tripId'] ?? '').toString();
    final boxId = (json['boxId'] ?? '').toString();
    final tripStopId = (json['tripStopId'] ?? '').toString();
    final statusText = json['statusText']?.toString();
    final failureCategory = json['failureReasonCategory']?.toString();
    final failureText = json['failureReasonText']?.toString();

    DateTime? deliveredAtUtc;
    if (json['deliveredAtUtc'] != null) {
      deliveredAtUtc = DateTime.tryParse(
        json['deliveredAtUtc'].toString(),
      )?.toUtc();
    }

    switch (eventType) {
      case 'box-delivered':
        return DriverOrderDeliveredEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          tripId: tripId,
          boxId: boxId,
          tripStopId: tripStopId,
          statusText: statusText,
          deliveredAtUtc: deliveredAtUtc,
        );

      case 'delivery-failed':
        return DriverDeliveryFailedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          tripId: tripId,
          boxId: boxId,
          tripStopId: tripStopId,
          statusText: statusText,
          failureReasonCategory: failureCategory,
          failureReasonText: failureText,
        );

      case 'driver-arrived-at-customer':
        return DriverArrivedAtCustomerEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          tripId: tripId,
          boxId: boxId,
          tripStopId: tripStopId,
          statusText: statusText,
        );

      case 'driver-requested-reassignment':
        return DriverReassignmentRequestedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          tripId: tripId,
          boxId: boxId,
          tripStopId: tripStopId,
          statusText: statusText,
          failureReasonCategory: failureCategory,
          failureReasonText: failureText,
        );

      case 'trip-in-transit':
        return DriverTripInTransitEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          tripId: tripId,
          tripStatusText: json['tripStatusText']?.toString(),
        );

      case 'box-assigned':
        return DriverBoxAssignedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          boxId: boxId,
          boxCode: json['boxCode']?.toString(),
          tripId: tripId,
          isReassigned: false,
        );

      case 'box-reassigned':
        return DriverBoxAssignedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          boxId: boxId,
          boxCode: json['boxCode']?.toString(),
          tripId: tripId,
          isReassigned: true,
        );

      case 'delivery-completed':
        final remaining =
            json['remainingBoxesCount'] ??
            json['remainingDeliveries'] ??
            json['remainingCount'] ??
            json['remaining'];
        return DriverDeliveryCompletedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          boxId: boxId,
          tripId: tripId,
          remainingBoxesCount: remaining is int
              ? remaining
              : int.tryParse(remaining?.toString() ?? ''),
        );

      case 'kitchen-ready':
        return DriverKitchenReadyEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          boxId: boxId,
          mealName: json['mealName']?.toString(),
        );

      case 'shift-status-confirmed':
      case 'ShiftStatusConfirmed':
      case 'shiftStatusConfirmed':
      case 'shift_status_confirmed':
        return DriverShiftStatusConfirmedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          status: (json['status'] ?? json['shiftStatus'] ?? '').toString(),
        );

      case 'dispatcher-message':
        return DriverDispatcherMessageEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          message: (json['message'] ?? json['text'] ?? '').toString(),
          title: json['title']?.toString(),
        );

      case 'connection-established':
        return DriverConnectionEstablishedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          connectionId: json['connectionId']?.toString(),
        );

      case 'tracking-not-required':
      case 'dispatcher.tracking_not_required':
        return DriverTrackingNotRequiredEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          reason: json['reason']?.toString(),
        );

      case 'driver-status-updated':
      case 'DriverStatusUpdated':
      case 'driverStatusUpdated':
      case 'driver_status_updated':
      case 'ShiftStatusUpdated':
      case 'shiftStatusUpdated':
      case 'shift_status_updated':
      case 'DriverStatusChanged':
      case 'driverStatusChanged':
      case 'driver-status-changed':
      case 'shift-status-changed':
        return DriverStatusUpdatedEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          driverId: json['driverId']?.toString(),
          shiftStatus: (json['shiftStatus'] ?? json['status'])?.toString(),
          statusText: json['statusText']?.toString(),
          isAvailable: json['isAvailable'] is bool
              ? json['isAvailable'] as bool
              : (json['isAvailable'] != null
                    ? json['isAvailable'].toString().toLowerCase() == 'true'
                    : null),
        );

      default:
        return DriverUnknownRealtimeEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          eventType: eventType,
        );
    }
  }
}

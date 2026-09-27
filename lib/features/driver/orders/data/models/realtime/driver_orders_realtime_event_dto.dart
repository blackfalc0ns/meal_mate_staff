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

      default:
        return DriverUnknownRealtimeEvent(
          eventId: eventId,
          occurredAtUtc: occurredAtUtc,
          eventType: eventType,
        );
    }
  }
}

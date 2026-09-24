import 'notification_payload.dart';

class NotificationPayloadParser {
  const NotificationPayloadParser();

  PushNotificationPayload parse(Map<String, dynamic> rawData) {
    final event = _extractEvent(rawData);
    if (event == null || event.isEmpty) {
      return UnsupportedNotificationPayload(
        rawData: rawData,
        reason: 'Missing event or type in notification data',
      );
    }

    final normalizedEvent = event.trim().toLowerCase();

    switch (normalizedEvent) {
      case 'driver.registration.restaurant_approved':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationRestaurantApprovedPayload(registrationId: id);

      case 'driver.registration.restaurant_changes_requested':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationChangesRequestedPayload(registrationId: id);

      case 'driver.registration.admin_confirmed':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationAdminConfirmedPayload(registrationId: id);

      case 'driver.registration.admin_rejected':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationAdminRejectedPayload(registrationId: id);

      case 'driver.registration.submitted':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationSubmittedPayload(registrationId: id);

      case 'driver.box.assigned':
      case 'box-assigned':
      case 'box_assigned':
        final id = _extractId(rawData, ['boxId', 'box_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing boxId for $normalizedEvent',
          );
        }
        return DriverBoxAssignedPayload(boxId: id);

      case 'driver.trip.assigned':
      case 'trip-assigned':
      case 'trip_assigned':
        final id = _extractId(rawData, ['tripId', 'trip_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing tripId for $normalizedEvent',
          );
        }
        return DriverTripAssignedPayload(tripId: id);

      case 'driver.trip.kitchen_ready':
      case 'kitchen-ready':
      case 'kitchen_ready':
        final id = _extractId(rawData, ['tripId', 'trip_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing tripId for $normalizedEvent',
          );
        }
        return DriverTripKitchenReadyPayload(tripId: id);

      case 'dispatcher.batch.ready':
      case 'batch-ready':
      case 'batch_ready':
        final id = _extractId(rawData, ['batchId', 'batch_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing batchId for $normalizedEvent',
          );
        }
        return DispatcherBatchReadyPayload(batchId: id);

      case 'incoming_call':
      case 'incoming-call':
        return IncomingCallPayload(rawData: rawData);

      default:
        return UnsupportedNotificationPayload(
          rawData: rawData,
          reason: 'Unknown event type: $event',
        );
    }
  }

  String? _extractEvent(Map<String, dynamic> data) {
    final candidate = data['event'] ?? data['eventType'] ?? data['type'];
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
    return null;
  }

  String? _extractId(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        final str = value.toString().trim();
        if (str.isNotEmpty) return str;
      }
    }
    return null;
  }
}

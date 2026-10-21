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
      case 'driver.registration.submitted':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationSubmittedPayload(registrationId: id);

      case 'driver.registration.independent_submitted':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationIndependentSubmittedPayload(
          registrationId: id,
        );

      case 'driver.registration.resubmitted':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationResubmittedPayload(registrationId: id);

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

      case 'driver.registration.restaurant_rejected':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationRestaurantRejectedPayload(registrationId: id);

      case 'driver.registration.admin_confirmed':
      case 'driver.registration.admin_approved':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationAdminConfirmedPayload(registrationId: id);

      case 'driver.registration.admin_changes_requested':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationAdminChangesRequestedPayload(
          registrationId: id,
        );

      case 'driver.registration.admin_rejected':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        if (id == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing registrationId for $normalizedEvent',
          );
        }
        return DriverRegistrationAdminRejectedPayload(registrationId: id);

      case 'driver.status.deep_link':
      case '/driver/status':
        final id = _extractId(rawData, ['registrationId', 'registration_id']);
        return DriverRegistrationStatusDeepLinkPayload(registrationId: id);

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

      case 'driver-support-issue':
      case 'driver_support_issue':
      case 'driver-support-issue-resolved':
      case 'driver_support_issue_resolved':
        final issueId = _extractId(rawData, [
          'subjectId',
          'subject_id',
          'issueId',
          'issue_id',
        ]) ?? _extractIssueIdFromLink(rawData);
        if (issueId == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing issueId for $normalizedEvent',
          );
        }
        final notificationId = _extractId(rawData, [
          'notificationId',
          'notification_id',
        ]);
        final deepLink = _extractString(rawData, ['deepLink', 'action', 'link']);
        return DispatcherDriverSupportIssuePayload(
          issueId: issueId,
          notificationId: notificationId,
          deepLink: deepLink,
        );

      case 'driver-support-handover':
      case 'driver_support_handover':
        final handoverId = _extractId(rawData, [
          'subjectId',
          'subject_id',
          'handoverId',
          'handover_id',
        ]) ?? _extractHandoverIdFromLink(rawData);
        if (handoverId == null) {
          return UnsupportedNotificationPayload(
            rawData: rawData,
            reason: 'Missing handoverId for $normalizedEvent',
          );
        }
        final notificationId = _extractId(rawData, [
          'notificationId',
          'notification_id',
        ]);
        final deepLink = _extractString(rawData, ['deepLink', 'action', 'link']);
        return DispatcherDriverSupportHandoverPayload(
          handoverId: handoverId,
          notificationId: notificationId,
          deepLink: deepLink,
        );

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
    final candidate =
        data['eventKey'] ?? data['event'] ?? data['eventType'] ?? data['type'];
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final nestedCandidate =
          nested['eventKey'] ??
          nested['event'] ??
          nested['eventType'] ??
          nested['type'];
      if (nestedCandidate is String && nestedCandidate.trim().isNotEmpty) {
        return nestedCandidate.trim();
      }
    }

    final link =
        data['link'] ?? data['route'] ?? data['deepLink'] ?? data['click_action'];
    if (link is String && link.contains('/driver/status')) {
      return 'driver.status.deep_link';
    }

    return null;
  }

  String? _extractString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        final str = value.toString().trim();
        if (str.isNotEmpty) return str;
      }
    }

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      for (final key in keys) {
        final value = nested[key];
        if (value != null) {
          final str = value.toString().trim();
          if (str.isNotEmpty) return str;
        }
      }
    }

    return null;
  }

  String? _extractIssueIdFromLink(Map<String, dynamic> data) {
    final link = _extractString(data, ['deepLink', 'action', 'link', 'route']);
    if (link == null) return null;
    final match = RegExp(r'/dispatcher/support/issues/([^/?]+)').firstMatch(link);
    return match?.group(1);
  }

  String? _extractHandoverIdFromLink(Map<String, dynamic> data) {
    final link = _extractString(data, ['deepLink', 'action', 'link', 'route']);
    if (link == null) return null;
    final match =
        RegExp(r'/dispatcher/support-handovers/([^/?]+)').firstMatch(link);
    return match?.group(1);
  }

  String? _extractId(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        final str = value.toString().trim();
        if (str.isNotEmpty) return str;
      }
    }

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      for (final key in keys) {
        final value = nested[key];
        if (value != null) {
          final str = value.toString().trim();
          if (str.isNotEmpty) return str;
        }
      }
    }

    final link =
        data['link'] ?? data['route'] ?? data['deepLink'] ?? data['click_action'];
    if (link is String && link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      if (uri != null) {
        for (final key in keys) {
          final queryVal = uri.queryParameters[key];
          if (queryVal != null && queryVal.trim().isNotEmpty) {
            return queryVal.trim();
          }
        }
      }
    }

    return null;
  }
}

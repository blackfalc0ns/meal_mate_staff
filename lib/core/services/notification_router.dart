import 'dart:collection';

import '../../config/routing/app_routes.dart';
import '../../config/routing/arguments/auth_route_arguments.dart';
import '../../features/account_status/domain/account_status_kind.dart';
import 'app_navigator_service.dart';
import 'notification_payload.dart';

class NotificationRouter {
  NotificationRouter({this.deduplicationWindow = const Duration(seconds: 10)});

  final Duration deduplicationWindow;
  final LinkedHashMap<String, DateTime> _handledMessages =
      LinkedHashMap<String, DateTime>();

  bool isDuplicate(String key, [DateTime? now]) {
    final current = now ?? DateTime.now();
    _cleanOldEntries(current);

    if (_handledMessages.containsKey(key)) {
      final handledAt = _handledMessages[key]!;
      if (current.difference(handledAt) < deduplicationWindow) {
        return true;
      }
    }
    _handledMessages[key] = current;
    return false;
  }

  void _cleanOldEntries(DateTime now) {
    _handledMessages.removeWhere(
      (_, timestamp) => now.difference(timestamp) >= deduplicationWindow,
    );
  }

  Future<bool> route(
    PushNotificationPayload payload, {
    String? messageId,
  }) async {
    final dedupKey = messageId ?? _generateFingerprint(payload);
    if (isDuplicate(dedupKey)) {
      return false;
    }

    final navigator = AppNavigatorService.navigator;
    if (navigator == null) {
      return false;
    }

    switch (payload) {
      case DriverRegistrationRestaurantApprovedPayload(:final registrationId):
        navigator.pushNamed(
          AppRoutes.accountStatus,
          arguments: AccountStatusRouteArgs(
            kind: AccountStatusKind.underReview,
            registrationId: registrationId,
          ),
        );
        return true;

      case DriverRegistrationChangesRequestedPayload(:final registrationId):
        navigator.pushNamed(
          AppRoutes.accountStatus,
          arguments: AccountStatusRouteArgs(
            kind: AccountStatusKind.moreInformationRequired,
            registrationId: registrationId,
          ),
        );
        return true;

      case DriverRegistrationAdminConfirmedPayload(:final registrationId):
        navigator.pushNamed(
          AppRoutes.accountStatus,
          arguments: AccountStatusRouteArgs(
            kind: AccountStatusKind.accepted,
            registrationId: registrationId,
          ),
        );
        return true;

      case DriverRegistrationAdminRejectedPayload(:final registrationId):
        navigator.pushNamed(
          AppRoutes.accountStatus,
          arguments: AccountStatusRouteArgs(
            kind: AccountStatusKind.rejected,
            registrationId: registrationId,
          ),
        );
        return true;

      case DriverBoxAssignedPayload():
      case DriverTripAssignedPayload():
      case DriverTripKitchenReadyPayload():
        navigator.pushNamed(AppRoutes.driverAssignedBoxes);
        return true;

      case DispatcherBatchReadyPayload():
        navigator.pushNamed(AppRoutes.dispatcherOrders);
        return true;

      case DriverRegistrationSubmittedPayload():
        navigator.pushNamed(AppRoutes.dispatcherHome);
        return true;

      case IncomingCallPayload():
      case UnsupportedNotificationPayload():
        return false;
    }
  }

  String _generateFingerprint(PushNotificationPayload payload) {
    return switch (payload) {
      DriverRegistrationRestaurantApprovedPayload(:final registrationId) =>
        'restaurant_approved:$registrationId',
      DriverRegistrationChangesRequestedPayload(:final registrationId) =>
        'changes_requested:$registrationId',
      DriverRegistrationAdminConfirmedPayload(:final registrationId) =>
        'admin_confirmed:$registrationId',
      DriverRegistrationAdminRejectedPayload(:final registrationId) =>
        'admin_rejected:$registrationId',
      DriverBoxAssignedPayload(:final boxId) => 'box_assigned:$boxId',
      DriverTripAssignedPayload(:final tripId) => 'trip_assigned:$tripId',
      DriverTripKitchenReadyPayload(:final tripId) => 'kitchen_ready:$tripId',
      DispatcherBatchReadyPayload(:final batchId) => 'batch_ready:$batchId',
      DriverRegistrationSubmittedPayload(:final registrationId) =>
        'submitted:$registrationId',
      IncomingCallPayload() => 'incoming_call:${payload.hashCode}',
      UnsupportedNotificationPayload() => 'unsupported:${payload.hashCode}',
    };
  }
}

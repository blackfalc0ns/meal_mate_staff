import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/notification_payload.dart';
import 'package:meal_mate_delivery/core/services/notification_payload_parser.dart';

void main() {
  const parser = NotificationPayloadParser();

  group('NotificationPayloadParser', () {
    test('parses driver.registration.restaurant_approved', () {
      final payload = parser.parse({
        'event': 'driver.registration.restaurant_approved',
        'registrationId': 'reg-123',
      });

      expect(
        payload,
        const DriverRegistrationRestaurantApprovedPayload(
          registrationId: 'reg-123',
        ),
      );
    });

    test('parses driver.registration.restaurant_changes_requested', () {
      final payload = parser.parse({
        'type': 'driver.registration.restaurant_changes_requested',
        'registration_id': 'reg-456',
      });

      expect(
        payload,
        const DriverRegistrationChangesRequestedPayload(
          registrationId: 'reg-456',
        ),
      );
    });

    test('parses driver.registration.admin_confirmed', () {
      final payload = parser.parse({
        'eventType': 'driver.registration.admin_confirmed',
        'registrationId': 'reg-789',
      });

      expect(
        payload,
        const DriverRegistrationAdminConfirmedPayload(
          registrationId: 'reg-789',
        ),
      );
    });

    test('parses driver.registration.admin_rejected', () {
      final payload = parser.parse({
        'event': 'driver.registration.admin_rejected',
        'registrationId': 'reg-999',
      });

      expect(
        payload,
        const DriverRegistrationAdminRejectedPayload(registrationId: 'reg-999'),
      );
    });

    test('parses driver.registration.submitted', () {
      final payload = parser.parse({
        'event': 'driver.registration.submitted',
        'registrationId': 'reg-111',
      });

      expect(
        payload,
        const DriverRegistrationSubmittedPayload(registrationId: 'reg-111'),
      );
    });

    test('parses canonical and alias driver.box.assigned', () {
      final canonical = parser.parse({
        'event': 'driver.box.assigned',
        'boxId': 'box-001',
      });
      final alias1 = parser.parse({
        'event': 'box-assigned',
        'box_id': 'box-001',
      });
      final alias2 = parser.parse({
        'event': 'box_assigned',
        'boxId': 'box-001',
      });

      expect(canonical, const DriverBoxAssignedPayload(boxId: 'box-001'));
      expect(alias1, const DriverBoxAssignedPayload(boxId: 'box-001'));
      expect(alias2, const DriverBoxAssignedPayload(boxId: 'box-001'));
    });

    test('parses canonical and alias driver.trip.assigned', () {
      final canonical = parser.parse({
        'event': 'driver.trip.assigned',
        'tripId': 'trip-101',
      });
      final alias = parser.parse({
        'event': 'trip-assigned',
        'trip_id': 'trip-101',
      });

      expect(canonical, const DriverTripAssignedPayload(tripId: 'trip-101'));
      expect(alias, const DriverTripAssignedPayload(tripId: 'trip-101'));
    });

    test('parses canonical and alias driver.trip.kitchen_ready', () {
      final canonical = parser.parse({
        'event': 'driver.trip.kitchen_ready',
        'tripId': 'trip-202',
      });
      final alias = parser.parse({
        'event': 'kitchen-ready',
        'tripId': 'trip-202',
      });

      expect(
        canonical,
        const DriverTripKitchenReadyPayload(tripId: 'trip-202'),
      );
      expect(alias, const DriverTripKitchenReadyPayload(tripId: 'trip-202'));
    });

    test('parses dispatcher.batch.ready', () {
      final payload = parser.parse({
        'event': 'dispatcher.batch.ready',
        'batchId': 'batch-303',
      });

      expect(payload, const DispatcherBatchReadyPayload(batchId: 'batch-303'));
    });

    test('parses incoming_call', () {
      final payload = parser.parse({
        'event': 'incoming_call',
        'callToken': 'token-secret',
      });

      expect(payload, isA<IncomingCallPayload>());
    });

    test('returns UnsupportedNotificationPayload when ID is missing', () {
      final payload = parser.parse({'event': 'driver.box.assigned'});

      expect(payload, isA<UnsupportedNotificationPayload>());
      final unsupported = payload as UnsupportedNotificationPayload;
      expect(unsupported.reason, contains('Missing boxId'));
    });

    test(
      'returns UnsupportedNotificationPayload when event is unknown or missing',
      () {
        final missingEvent = parser.parse({'someKey': 'value'});
        expect(missingEvent, isA<UnsupportedNotificationPayload>());

        final unknownEvent = parser.parse({
          'event': 'random.unsupported.event',
        });
        expect(unknownEvent, isA<UnsupportedNotificationPayload>());
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/realtime/driver_orders_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_signalr_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';

void main() {
  group('DriverOrdersRealtimeEventDto driver-status-updated parser', () {
    test('parses driver-status-updated payload correctly', () {
      final json = <String, dynamic>{
        'eventId': 'evt-555',
        'occurredAtUtc': '2026-10-05T09:30:00Z',
        'driverId': 'drv-123',
        'shiftStatus': 'Active',
        'statusText': 'متاح',
        'isAvailable': true,
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'driver-status-updated',
        json,
      );

      expect(event, isA<DriverStatusUpdatedEvent>());
      final statusEvent = event as DriverStatusUpdatedEvent;
      expect(statusEvent.eventId, 'evt-555');
      expect(statusEvent.driverId, 'drv-123');
      expect(statusEvent.shiftStatus, 'Active');
      expect(statusEvent.statusText, 'متاح');
      expect(statusEvent.isAvailable, true);
    });

    test('supports driver-status-updated in DriverOrdersSignalRClient.supportedEvents', () {
      expect(
        DriverOrdersSignalRClient.supportedEvents.contains('driver-status-updated'),
        isTrue,
      );
    });
  });
}

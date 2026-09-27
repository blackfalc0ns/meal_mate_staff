import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/realtime/driver_orders_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';

void main() {
  group('Driver Orders Realtime Mapper Tests', () {
    test('maps box-delivered payload correctly', () {
      final json = {
        'eventId': 'evt-1',
        'tripId': 'trip-1',
        'boxId': 'box-1',
        'tripStopId': 'stop-1',
        'statusText': 'تم التسليم',
        'occurredAtUtc': '2026-09-27T10:00:00Z',
        'deliveredAtUtc': '2026-09-27T09:59:50Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'box-delivered',
        json,
      );

      expect(event, isA<DriverOrderDeliveredEvent>());
      final delivered = event as DriverOrderDeliveredEvent;
      expect(delivered.eventId, 'evt-1');
      expect(delivered.tripId, 'trip-1');
      expect(delivered.boxId, 'box-1');
      expect(delivered.tripStopId, 'stop-1');
      expect(delivered.statusText, 'تم التسليم');
      expect(delivered.occurredAtUtc, DateTime.parse('2026-09-27T10:00:00Z'));
      expect(delivered.deliveredAtUtc, DateTime.parse('2026-09-27T09:59:50Z'));
    });

    test('maps delivery-failed payload with failure reasons', () {
      final json = {
        'eventId': 'evt-2',
        'tripId': 'trip-1',
        'boxId': 'box-2',
        'tripStopId': 'stop-2',
        'statusText': 'فشل التسليم',
        'failureReasonCategory': 'CustomerUnavailable',
        'failureReasonText': 'لم يجيب العميل',
        'occurredAtUtc': '2026-09-27T10:05:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'delivery-failed',
        json,
      );

      expect(event, isA<DriverDeliveryFailedEvent>());
      final failed = event as DriverDeliveryFailedEvent;
      expect(failed.eventId, 'evt-2');
      expect(failed.failureReasonCategory, 'CustomerUnavailable');
      expect(failed.failureReasonText, 'لم يجيب العميل');
    });

    test('maps driver-arrived-at-customer payload', () {
      final json = {
        'eventId': 'evt-3',
        'tripId': 'trip-1',
        'boxId': 'box-3',
        'tripStopId': 'stop-3',
        'statusText': 'وصل السائق للعميل',
        'occurredAtUtc': '2026-09-27T10:10:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'driver-arrived-at-customer',
        json,
      );

      expect(event, isA<DriverArrivedAtCustomerEvent>());
      final arrived = event as DriverArrivedAtCustomerEvent;
      expect(arrived.eventId, 'evt-3');
      expect(arrived.statusText, 'وصل السائق للعميل');
    });

    test('maps driver-requested-reassignment payload', () {
      final json = {
        'eventId': 'evt-4',
        'tripId': 'trip-1',
        'boxId': 'box-4',
        'tripStopId': 'stop-4',
        'statusText': 'تم طلب إعادة التعيين',
        'failureReasonCategory': 'VehicleIssue',
        'failureReasonText': 'عطل في المركبة',
        'occurredAtUtc': '2026-09-27T10:15:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'driver-requested-reassignment',
        json,
      );

      expect(event, isA<DriverReassignmentRequestedEvent>());
      final reassign = event as DriverReassignmentRequestedEvent;
      expect(reassign.eventId, 'evt-4');
      expect(reassign.failureReasonCategory, 'VehicleIssue');
    });

    test('maps trip-in-transit payload', () {
      final json = {
        'eventId': 'evt-5',
        'tripId': 'trip-1',
        'tripStatusText': 'خارج للتوصيل',
        'occurredAtUtc': '2026-09-27T08:00:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'trip-in-transit',
        json,
      );

      expect(event, isA<DriverTripInTransitEvent>());
      final inTransit = event as DriverTripInTransitEvent;
      expect(inTransit.eventId, 'evt-5');
      expect(inTransit.tripId, 'trip-1');
      expect(inTransit.tripStatusText, 'خارج للتوصيل');
    });

    test('handles unknown event types gracefully without throwing', () {
      final json = {
        'eventId': 'evt-6',
        'occurredAtUtc': '2026-09-27T12:00:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'future-unsupported-event',
        json,
      );

      expect(event, isA<DriverUnknownRealtimeEvent>());
      final unknown = event as DriverUnknownRealtimeEvent;
      expect(unknown.eventId, 'evt-6');
      expect(unknown.eventType, 'future-unsupported-event');
    });

    test('handles malformed or missing timestamps defensively', () {
      final json = {
        'eventId': 'evt-7',
        'tripId': 'trip-1',
        'boxId': 'box-1',
        'tripStopId': 'stop-1',
        'occurredAtUtc': 'not-a-valid-date',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'box-delivered',
        json,
      );
      expect(event, isA<DriverOrderDeliveredEvent>());
      expect(event.eventId, 'evt-7');
      expect(event.occurredAtUtc, isNotNull);
    });
  });
}

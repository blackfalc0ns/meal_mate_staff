import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Driver Orders Contract Gate Test', () {
    late Map<String, dynamic> contractJson;

    setUpAll(() {
      final file = File(
        'test/features/driver/orders/fixtures/driver_delivery_manifest.json',
      );
      final jsonString = file.readAsStringSync();
      contractJson = jsonDecode(jsonString) as Map<String, dynamic>;
    });

    test('validates exact top-level keys', () {
      final expectedTopLevelKeys = {
        'tripId',
        'tripCode',
        'tripStatus',
        'tripStatusText',
        'serverTimeUtc',
        'counts',
        'stops',
      };

      expect(contractJson.keys.toSet(), equals(expectedTopLevelKeys));
    });

    test('validates counts object keys', () {
      final counts = contractJson['counts'] as Map<String, dynamic>;
      final expectedCountKeys = {'total', 'inProgress', 'delivered', 'failed'};

      expect(counts.keys.toSet(), equals(expectedCountKeys));
      expect(counts['total'], isA<int>());
      expect(counts['inProgress'], isA<int>());
      expect(counts['delivered'], isA<int>());
      expect(counts['failed'], isA<int>());
    });

    test('validates exact stop keys for all stops', () {
      final stops = contractJson['stops'] as List<dynamic>;
      expect(stops, isNotEmpty);

      final expectedStopKeys = {
        'tripStopId',
        'boxId',
        'boxCode',
        'sequenceNumber',
        'customerName',
        'deliveryZone',
        'formattedAddress',
        'latitude',
        'longitude',
        'mealsCount',
        'mealsSummary',
        'deliveryTimeSlot',
        'status',
        'statusText',
        'deliveredAtUtc',
        'failureReasonCategory',
        'failureReasonText',
        'isCurrentStop',
        'canCompleteDelivery',
        'canNavigate',
        'canCallCustomer',
        'maskedPhoneNumber',
      };

      for (final stopRaw in stops) {
        final stop = stopRaw as Map<String, dynamic>;
        expect(
          stop.keys.toSet(),
          equals(expectedStopKeys),
          reason: 'Stop ${stop['boxCode']} missing or extra keys',
        );
      }
    });

    test('contains required statuses for contract verification', () {
      final stops = contractJson['stops'] as List<dynamic>;
      final statuses = stops.map((s) => (s as Map)['status']).toSet();

      expect(statuses, contains('InProgress'));
      expect(statuses, contains('Delivered'));
      expect(statuses, contains('Failed'));
      expect(statuses, contains('CustomFutureStatus'));
    });
  });
}

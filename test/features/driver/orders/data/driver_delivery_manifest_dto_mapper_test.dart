import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/mapper/driver_delivery_manifest_mapper.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_call_proxy_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_delivery_manifest_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';

void main() {
  group('Driver Delivery Manifest DTO & Mapper Tests', () {
    test('parses full contract fixture without throwing', () {
      final file = File(
        'test/features/driver/orders/fixtures/driver_delivery_manifest.json',
      );
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final dto = DriverDeliveryManifestResponseDto.fromJson(json);

      expect(dto.tripId, '7ea85f64-5717-4562-b3fc-2c963f66af10');
      expect(dto.tripCode, 'TRP-48-8752');
      expect(dto.tripStatus, 'InProgress');
      expect(dto.counts?.total, 8);
      expect(dto.counts?.inProgress, 2);
      expect(dto.counts?.delivered, 5);
      expect(dto.counts?.failed, 1);
      expect(dto.stops?.length, 4);

      final stop2 = dto.stops![1];
      expect(stop2.boxCode, 'BX-458622');
      expect(stop2.latitude, 29.3375);
      expect(stop2.longitude, 48.0758);
      expect(stop2.isCurrentStop, true);
      expect(stop2.maskedPhoneNumber, '+965*****123');
    });

    test('handles sparse and missing json fields defensively', () {
      final sparseJson = <String, dynamic>{
        'serverTimeUtc': 'invalid-date-format',
        'stops': [
          <String, dynamic>{
            'sequenceNumber': null,
            'latitude': 29, // int instead of double
            'longitude': 48.1,
            'status': 'UNKNOWN_CUSTOM_VALUE',
          }
        ],
      };

      final dto = DriverDeliveryManifestResponseDto.fromJson(sparseJson);

      expect(dto.tripId, isNull);
      expect(dto.counts, isNull);
      expect(dto.stops, isNotNull);
      expect(dto.stops!.first.boxId, isNull);
      expect(dto.stops!.first.latitude, 29);

      final entity = dto.toEntity();
      expect(entity.tripId, isNull);
      expect(entity.hasActiveTrip, false);
      expect(entity.totalCount, 0);
      expect(entity.inProgressCount, 0);
      expect(entity.stops.length, 1);

      final stopEntity = entity.stops.first;
      expect(stopEntity.sequenceNumber, 0);
      expect(stopEntity.latitude, 29.0);
      expect(stopEntity.longitude, 48.1);
      expect(stopEntity.status, DriverDeliveryStatus.unknown);
      expect(stopEntity.customerName, '');
      expect(stopEntity.formattedAddress, '');
      expect(stopEntity.maskedPhoneNumber, isNull);
    });

    test('maps case-insensitive known statuses and preserves unknown status', () {
      final statuses = {
        'pending': DriverDeliveryStatus.pending,
        'Pending': DriverDeliveryStatus.pending,
        'inProgress': DriverDeliveryStatus.inProgress,
        'INPROGRESS': DriverDeliveryStatus.inProgress,
        'arrivedAtCustomer': DriverDeliveryStatus.arrivedAtCustomer,
        'ArrivedAtCustomer': DriverDeliveryStatus.arrivedAtCustomer,
        'delivered': DriverDeliveryStatus.delivered,
        'Delivered': DriverDeliveryStatus.delivered,
        'failed': DriverDeliveryStatus.failed,
        'FAILED': DriverDeliveryStatus.failed,
        'reassignmentRequested': DriverDeliveryStatus.reassignmentRequested,
        'ReassignmentRequested': DriverDeliveryStatus.reassignmentRequested,
        'unsupported_status_xyz': DriverDeliveryStatus.unknown,
        null: DriverDeliveryStatus.unknown,
      };

      for (final entry in statuses.entries) {
        expect(
          DriverDeliveryStatusX.fromWire(entry.key),
          entry.value,
          reason: 'Failed mapping status ${entry.key}',
        );
      }
    });

    test('sorts stops deterministically by sequenceNumber and boxId', () {
      final rawStops = [
        DriverDeliveryStopResponseDto(
          tripStopId: 's3',
          boxId: 'box-b',
          sequenceNumber: 2,
        ),
        DriverDeliveryStopResponseDto(
          tripStopId: 's1',
          boxId: 'box-a',
          sequenceNumber: 1,
        ),
        DriverDeliveryStopResponseDto(
          tripStopId: 's2',
          boxId: 'box-a',
          sequenceNumber: 2,
        ),
      ];

      final dto = DriverDeliveryManifestResponseDto(
        tripId: 'trip-1',
        stops: rawStops,
      );

      final entity = dto.toEntity();
      expect(entity.stops[0].tripStopId, 's1');
      expect(entity.stops[1].tripStopId, 's2'); // tie-break box-a before box-b
      expect(entity.stops[2].tripStopId, 's3');
    });

    test('clamps negative counts to 0 and parses dates safely', () {
      final dto = DriverDeliveryManifestResponseDto(
        serverTimeUtc: '2026-09-27T12:00:00Z',
        counts: DriverDeliveryCountsResponseDto(
          total: -5,
          inProgress: -2,
          delivered: 10,
          failed: -1,
        ),
      );

      final entity = dto.toEntity();
      expect(entity.totalCount, 0);
      expect(entity.inProgressCount, 0);
      expect(entity.deliveredCount, 10);
      expect(entity.failedCount, 0);
      expect(entity.serverTimeUtc?.isUtc, true);
    });

    test('parses call proxy dto and maps to entity', () {
      final json = {
        'boxId': 'box-123',
        'callableUri': 'tel:+96512345678',
        'phoneNumber': '+96512345678',
        'expiresAtUtc': '2026-09-27T15:00:00Z',
      };

      final dto = DriverCallProxyResponseDto.fromJson(json);
      expect(dto.boxId, 'box-123');
      expect(dto.callableUri, 'tel:+96512345678');

      final entity = dto.toEntity();
      expect(entity.boxId, 'box-123');
      expect(entity.callableUri, 'tel:+96512345678');
      expect(entity.phoneNumber, '+96512345678');
      expect(entity.expiresAtUtc, isNotNull);
    });
  });
}

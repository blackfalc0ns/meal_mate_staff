import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/mapper/driver_reassignment_mapper.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/models/response/driver_reassignment_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_request_entity.dart';

void main() {
  group('DriverReassignmentMapper Tests', () {
    test('all 5 canonical reasons map to correct wire strings and back', () {
      final reasons = {
        ReassignmentReason.vehicleBreakdown: 'VehicleBreakdown',
        ReassignmentReason.trafficAccident: 'TrafficAccident',
        ReassignmentReason.medicalOrPersonalEmergency:
            'MedicalOrPersonalEmergency',
        ReassignmentReason.deviceFailure: 'DeviceFailure',
        ReassignmentReason.otherOperationalReason: 'OtherOperationalReason',
      };

      for (final entry in reasons.entries) {
        expect(entry.key.toWire(), equals(entry.value));
        expect(ReassignmentReasonMapper.fromWire(entry.value), equals(entry.key));
      }

      expect(
        () => ReassignmentReasonMapper.fromWire('UnknownWireReason'),
        throwsA(isA<FormatException>()),
      );
    });

    test('request entity serialization trims notes, omits empty notes, and sends valid coordinates pair', () {
      // Empty notes -> notes is null in DTO
      const reqEmptyNotes = ReassignmentRequestEntity(
        reason: ReassignmentReason.vehicleBreakdown,
        notes: '   ',
      );
      final dtoEmpty = reqEmptyNotes.toDto();
      expect(dtoEmpty.reason, equals('VehicleBreakdown'));
      expect(dtoEmpty.notes, isNull);
      expect(dtoEmpty.latitude, isNull);
      expect(dtoEmpty.longitude, isNull);

      // Notes populated and trimmed, valid coordinates pair included
      const reqWithData = ReassignmentRequestEntity(
        reason: ReassignmentReason.trafficAccident,
        notes: ' Flat tire on highway ',
        latitude: 29.3759,
        longitude: 47.9774,
      );
      final dtoWithData = reqWithData.toDto();
      expect(dtoWithData.reason, equals('TrafficAccident'));
      expect(dtoWithData.notes, equals('Flat tire on highway'));
      expect(dtoWithData.latitude, equals(29.3759));
      expect(dtoWithData.longitude, equals(47.9774));

      // Incomplete coordinates pair (e.g. only latitude) -> omit both
      const reqIncompleteCoords = ReassignmentRequestEntity(
        reason: ReassignmentReason.deviceFailure,
        latitude: 29.3759,
        longitude: null,
      );
      final dtoIncomplete = reqIncompleteCoords.toDto();
      expect(dtoIncomplete.latitude, isNull);
      expect(dtoIncomplete.longitude, isNull);

      // Out of range coordinates -> omit both
      const reqOutOfRange = ReassignmentRequestEntity(
        reason: ReassignmentReason.deviceFailure,
        latitude: 95.0, // Invalid latitude
        longitude: 47.0,
      );
      final dtoOutOfRange = reqOutOfRange.toDto();
      expect(dtoOutOfRange.latitude, isNull);
      expect(dtoOutOfRange.longitude, isNull);
    });

    test('response DTO maps to entity with UTC datetime parsing and fallback target boxId', () {
      const responseDto = DriverReassignmentResponseDto(
        requestId: 'f4444444-4444-4444-4444-444444444444',
        boxId: 'c2222222-2222-2222-2222-222222222222',
        boxCode: '#BX-1256',
        status: 'ReassignmentRequested',
        message: 'Request pending review',
        requestedAtUtc: '2026-10-07T08:45:00Z',
      );

      final entity = responseDto.toEntity(
        targetBoxId: 'c2222222-2222-2222-2222-222222222222',
      );

      expect(entity.requestId, equals('f4444444-4444-4444-4444-444444444444'));
      expect(entity.boxId, equals('c2222222-2222-2222-2222-222222222222'));
      expect(entity.boxCode, equals('#BX-1256'));
      expect(entity.status, equals('ReassignmentRequested'));
      expect(entity.message, equals('Request pending review'));
      expect(entity.requestedAtUtc, equals(DateTime.utc(2026, 10, 7, 8, 45)));

      // Missing boxId in response falls back to targetBoxId
      const responseMissingBoxId = DriverReassignmentResponseDto(
        requestId: 'req-123',
        status: 'ReassignmentRequested',
      );
      final entityFallback = responseMissingBoxId.toEntity(targetBoxId: 'fallback-box-id');
      expect(entityFallback.boxId, equals('fallback-box-id'));
    });

    test('malformed response rejects empty requestId, missing status, or mismatched boxId', () {
      // Missing / empty requestId
      const missingReqId = DriverReassignmentResponseDto(
        requestId: '   ',
        status: 'ReassignmentRequested',
      );
      expect(
        () => missingReqId.toEntity(targetBoxId: 'box-1'),
        throwsA(isA<FormatException>()),
      );

      // Missing / empty status
      const missingStatus = DriverReassignmentResponseDto(
        requestId: 'req-1',
        status: '',
      );
      expect(
        () => missingStatus.toEntity(targetBoxId: 'box-1'),
        throwsA(isA<FormatException>()),
      );

      // Mismatched boxId
      const mismatchedBoxId = DriverReassignmentResponseDto(
        requestId: 'req-1',
        boxId: 'different-box-uuid',
        status: 'ReassignmentRequested',
      );
      expect(
        () => mismatchedBoxId.toEntity(targetBoxId: 'expected-box-uuid'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

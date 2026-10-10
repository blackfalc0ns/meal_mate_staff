import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/mapper/calling_dto_mapper.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/realtime/voice_call_envelope_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/delivery_contact_case_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/phone_grant_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/voice_call_eligibility_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/voice_call_snapshot_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/voice_device_register_response_dto.dart';
import 'package:meal_mate_delivery/features/device_token/data/models/response/driver_device_token_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/voice_call_display_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_status.dart';

void main() {
  group('Voice Calls v2 DTO & Mapper Tests', () {
    test('VoiceCallStatus extension correctly determines terminal states', () {
      expect(VoiceCallStatus.failed.isTerminal, isTrue);
      expect(VoiceCallStatus.rejected.isTerminal, isTrue);
      expect(VoiceCallStatus.cancelled.isTerminal, isTrue);
      expect(VoiceCallStatus.missed.isTerminal, isTrue);
      expect(VoiceCallStatus.ended.isTerminal, isTrue);
      expect(VoiceCallStatus.created.isTerminal, isFalse);
      expect(VoiceCallStatus.ringing.isTerminal, isFalse);
      expect(VoiceCallStatus.accepted.isTerminal, isFalse);
      expect(VoiceCallStatus.connecting.isTerminal, isFalse);
      expect(VoiceCallStatus.active.isTerminal, isFalse);
    });

    test('VoiceCallSnapshotResponseDto deserialization and mapping', () {
      final json = {
        'callId': 'c-123',
        'tripStopId': 'ts-456',
        'status': 'Accepted',
        'reasonCode': null,
        'sequence': 4,
        'createdAtUtc': '2026-10-10T03:00:00Z',
        'connectedAtUtc': '2026-10-10T03:00:05Z',
        'endedAtUtc': null,
        'durationSeconds': 15,
        'hasRecordedAudio': false,
      };

      final dto = VoiceCallSnapshotResponseDto.fromJson(json);
      expect(dto.callId, 'c-123');
      expect(dto.status, 'Accepted');
      expect(dto.sequence, 4);

      final entity = CallingDtoMapper.toSnapshotEntity(dto);
      expect(entity.callId, 'c-123');
      expect(entity.tripStopId, 'ts-456');
      expect(entity.status, VoiceCallStatus.accepted);
      expect(entity.durationSeconds, 15);
      expect(entity.connectedAtUtc, isNotNull);
    });

    test('VoiceCallEnvelopeDto deserializes realtime envelopes', () {
      final json = {
        'eventId': 'ev-789',
        'callId': 'c-123',
        'eventType': 'StatusChanged',
        'sequence': 5,
        'timestampUtc': '2026-10-10T03:00:06Z',
        'payload': {
          'callId': 'c-123',
          'tripStopId': 'ts-456',
          'status': 'Active',
          'sequence': 5,
          'createdAtUtc': '2026-10-10T03:00:00Z',
        },
      };

      final envelope = VoiceCallEnvelopeDto.fromJson(json);
      expect(envelope.eventId, 'ev-789');
      expect(envelope.callId, 'c-123');
      expect(envelope.eventType, 'StatusChanged');
      expect(envelope.sequence, 5);
      expect(envelope.payload?['status'], 'Active');
    });

    test('VoiceCallEligibilityResponseDto deserialization and mapping', () {
      final json = {
        'canInitiate': true,
        'reasonCode': 'OK',
        'distanceMeters': 120.5,
        'locationAgeSeconds': 10,
        'canHold': true,
        'canRetry': true,
        'canRevealPhone': false,
        'contactCaseId': 'case-01',
      };

      final dto = VoiceCallEligibilityResponseDto.fromJson(json);
      expect(dto.canInitiate, isTrue);
      expect(dto.distanceMeters, 120.5);

      final entity = CallingDtoMapper.toEligibilityEntity(dto);
      expect(entity.canInitiate, isTrue);
      expect(entity.canHold, isTrue);
      expect(entity.canRevealPhone, isFalse);
      expect(entity.contactCaseId, 'case-01');
    });

    test('VoiceDeviceRegisterResponseDto deserialization and mapping', () {
      final json = {
        'deviceSessionId': 'sess-999',
        'controlProof': 'proof-secret',
        'expiresAtUtc': '2026-10-11T03:00:00Z',
      };

      final dto = VoiceDeviceRegisterResponseDto.fromJson(json);
      expect(dto.deviceSessionId, 'sess-999');

      final entity = CallingDtoMapper.toDeviceSessionEntity(dto);
      expect(entity.deviceSessionId, 'sess-999');
      expect(entity.controlProof, 'proof-secret');
    });

    test('DeliveryContactCaseResponseDto deserialization and mapping', () {
      final json = {
        'contactCaseId': 'case-100',
        'tripStopId': 'ts-456',
        'status': 'Open',
        'firstAttemptCallId': 'c-123',
        'holdExpiresAtUtc': '2026-10-10T03:15:00Z',
        'canResume': true,
        'canRevealPhone': true,
        'notes': 'Customer phone busy',
      };

      final dto = DeliveryContactCaseResponseDto.fromJson(json);
      expect(dto.contactCaseId, 'case-100');

      final entity = CallingDtoMapper.toContactCaseEntity(dto);
      expect(entity.contactCaseId, 'case-100');
      expect(entity.tripStopId, 'ts-456');
      expect(entity.firstAttemptCallId, 'c-123');
      expect(entity.canResume, isTrue);
      expect(entity.canRevealPhone, isTrue);
    });

    test('PhoneGrantResponseDto deserialization and mapping', () {
      final json = {
        'grantId': 'grant-01',
        'expiresAtUtc': '2026-10-10T03:05:00Z',
        'customerPhone': '+201000000000',
        'contactCaseId': 'case-100',
      };

      final dto = PhoneGrantResponseDto.fromJson(json);
      expect(dto.grantId, 'grant-01');
      expect(dto.customerPhone, '+201000000000');

      final entity = CallingDtoMapper.toPhoneGrantEntity(dto);
      expect(entity.grantId, 'grant-01');
      expect(entity.customerPhone, '+201000000000');
    });

    test('VoiceCallDisplayResponseDto deserialization and mapping', () {
      final json = {
        'callId': 'c-123',
        'tripStopId': 'ts-456',
        'driverName': 'Captain Driver',
        'driverImageUrl': '/images/driver.jpg',
        'driverRole': 'مندوب التوصيل',
        'vehicleType': 'Motorcycle',
        'plateNumber': '1234 ABC',
        'deliveryAddress': '123 Nile Corniche',
        'deliveryZone': 'Zamalek',
        'orderCode': 'ORD-9988',
        'mealSummary': '2x Burger Meal',
        'slotLabel': 'Stop #1',
        'boxCount': 2,
        'stopStatus': 'Active',
      };

      final dto = VoiceCallDisplayResponseDto.fromJson(json);
      expect(dto.callId, 'c-123');
      expect(dto.driverName, 'Captain Driver');
      expect(dto.deliveryAddress, '123 Nile Corniche');
      expect(dto.deliveryZone, 'Zamalek');

      final entity = CallingDtoMapper.toDisplayEntity(dto);
      expect(entity.callId, 'c-123');
      expect(entity.driverName, 'Captain Driver');
      expect(entity.deliveryAddress, '123 Nile Corniche');
      expect(entity.deliveryZone, 'Zamalek');
      expect(entity.orderCode, 'ORD-9988');
      expect(entity.mealSummary, '2x Burger Meal');
    });

    test('DriverDeviceTokenResponseDto deserialization', () {
      final json = {
        'fcmDeviceTokenId': 'tok-guid-1234',
      };

      final dto = DriverDeviceTokenResponseDto.fromJson(json);
      expect(dto.fcmDeviceTokenId, 'tok-guid-1234');
    });
  });
}

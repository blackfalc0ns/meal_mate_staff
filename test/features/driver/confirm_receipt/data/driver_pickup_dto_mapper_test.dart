import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/mapper/driver_pickup_mapper.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_barcode_validation_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_condition_photo_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_pickup_confirmation_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_pickup_summary_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_trip_start_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/confirm_driver_pickup_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_pickup_confirmation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/start_driver_trip_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/validate_driver_barcode_request_entity.dart';

void main() {
  group('Request Entity -> DTO Mappers', () {
    test('ValidateDriverBarcodeRequestEntity maps to DTO', () {
      const entity = ValidateDriverBarcodeRequestEntity(
        barcodeValue: 'BOX-1256',
      );
      final dto = entity.toDto();
      expect(dto.barcodeValue, 'BOX-1256');
    });

    test('ConfirmDriverPickupRequestEntity maps to DTO', () {
      const entity = ConfirmDriverPickupRequestEntity(
        validationToken: 'token-abc',
        conditionPhotoStorageKey: 'photos/key.jpg',
        latitude: 29.3375,
        longitude: 48.0280,
      );
      final dto = entity.toDto();
      expect(dto.validationToken, 'token-abc');
      expect(dto.conditionPhotoStorageKey, 'photos/key.jpg');
      expect(dto.latitude, 29.3375);
      expect(dto.longitude, 48.0280);
    });

    test('StartDriverTripRequestEntity maps to DTO', () {
      const entity = StartDriverTripRequestEntity(
        latitude: 29.3375,
        longitude: 48.0280,
      );
      final dto = entity.toDto();
      expect(dto.latitude, 29.3375);
      expect(dto.longitude, 48.0280);
    });
  });

  group('DriverBarcodeValidationResponseDto & Mapper', () {
    const rawJson = {
      'boxId': 'box-101',
      'boxCode': 'BOX-1256',
      'customerName': 'Ahmed',
      'deliveryZone': 'حي النرجس',
      'mealsCount': 3,
      'deliveryTimeSlot': '12:00 PM - 02:00 PM',
      'validationToken': 'token-xyz',
      'expiresAtUtc': '2026-09-27T10:15:00Z',
      'status': 'BarcodeValidated',
      'statusText': 'تم مسح الرمز بنجاح',
      'nextAction': 'CaptureConditionPhoto',
      'message': 'Success',
    };

    test('parses exact JSON correctly', () {
      final dto = DriverBarcodeValidationResponseDto.fromJson(rawJson);
      expect(dto.boxId, 'box-101');
      expect(dto.boxCode, 'BOX-1256');
      expect(dto.validationToken, 'token-xyz');
      expect(dto.expiresAtUtc, '2026-09-27T10:15:00Z');
      expect(dto.nextAction, 'CaptureConditionPhoto');
    });

    test('maps to entity with safe defaults', () {
      final dto = DriverBarcodeValidationResponseDto.fromJson(rawJson);
      final entity = dto.toEntity();

      expect(entity.boxId, 'box-101');
      expect(entity.boxCode, 'BOX-1256');
      expect(entity.validationToken, 'token-xyz');
      expect(entity.expiresAtUtc, DateTime.parse('2026-09-27T10:15:00Z'));
      expect(entity.nextAction, 'CaptureConditionPhoto');
    });

    test('handles empty DTO defensively', () {
      const emptyDto = DriverBarcodeValidationResponseDto();
      final entity = emptyDto.toEntity();

      expect(entity.boxId, '');
      expect(entity.validationToken, '');
      expect(entity.expiresAtUtc, isNull);
    });
  });

  group('DriverConditionPhotoUploadResponseDto & Mapper', () {
    const rawJson = {
      'boxId': 'box-101',
      'conditionPhotoStorageKey': 'photos/storage-key.jpg',
      'uploadedAtUtc': '2026-09-27T10:05:00Z',
      'status': 'PhotoUploaded',
      'statusText': 'تم رفع صورة البوكس',
      'nextAction': 'ConfirmPickup',
      'message': 'Photo uploaded successfully',
    };

    test('parses exact JSON and maps to entity', () {
      final dto = DriverConditionPhotoUploadResponseDto.fromJson(rawJson);
      expect(dto.conditionPhotoStorageKey, 'photos/storage-key.jpg');

      final entity = dto.toEntity();
      expect(entity.boxId, 'box-101');
      expect(entity.conditionPhotoStorageKey, 'photos/storage-key.jpg');
      expect(entity.uploadedAtUtc, DateTime.parse('2026-09-27T10:05:00Z'));
      expect(entity.nextAction, 'ConfirmPickup');
    });
  });

  group('DriverPickupConfirmationResponseDto & Mapper', () {
    const rawJson = {
      'boxId': 'box-101',
      'boxCode': 'BOX-1256',
      'tripId': 'trip-001',
      'confirmedAtUtc': '2026-09-27T10:06:00Z',
      'status': 'PickedUp',
      'statusText': 'تم تأكيد الاستلام',
      'nextAction': 'ShowBoxSuccess',
      'pickedUpBoxesCount': 1,
      'totalBoxesCount': 8,
      'allBoxesPickedUp': false,
      'message': 'Box pickup confirmed',
    };

    test('parses exact JSON and maps to entity', () {
      final dto = DriverPickupConfirmationResponseDto.fromJson(rawJson);
      expect(dto.boxId, 'box-101');
      expect(dto.tripId, 'trip-001');
      expect(dto.nextAction, 'ShowBoxSuccess');

      final entity = dto.toEntity();
      expect(entity.boxId, 'box-101');
      expect(entity.tripId, 'trip-001');
      expect(entity.nextAction, DriverPickupNextAction.showBoxSuccess);
      expect(entity.allBoxesPickedUp, false);
      expect(entity.pickedUpBoxesCount, 1);
      expect(entity.totalBoxesCount, 8);
    });

    test('maps ShowPickupSummary nextAction correctly', () {
      const summaryDto = DriverPickupConfirmationResponseDto(
        nextAction: 'ShowPickupSummary',
        allBoxesPickedUp: true,
      );
      final entity = summaryDto.toEntity();
      expect(entity.nextAction, DriverPickupNextAction.showPickupSummary);
      expect(entity.allBoxesPickedUp, true);
    });
  });

  group('DriverPickupSummaryResponseDto & Mapper', () {
    const rawJson = {
      'tripId': 'trip-001',
      'tripCode': 'TRIP-101',
      'driverId': 'drv-001',
      'driverName': 'Ahmed',
      'assignedBoxesCount': 8,
      'validatedBoxesCount': 8,
      'receivedBoxesCount': 8,
      'totalBoxesCount': 8,
      'pickedUpBoxesCount': 8,
      'allBoxesPickedUp': true,
      'canStartTrip': true,
      'boxes': [
        {
          'boxId': 'box-101',
          'boxCode': 'BOX-1256',
          'customerName': 'Ahmed',
          'deliveryZone': 'حي النرجس',
          'mealsCount': 3,
          'status': 'PickedUp',
          'statusText': 'تم الاستلام',
          'isReceived': true,
          'conditionPhotoStorageKey': 'photos/box-101.jpg',
        },
      ],
      'message': 'Summary loaded',
    };

    test('parses exact summary JSON and maps to entity', () {
      final dto = DriverPickupSummaryResponseDto.fromJson(rawJson);
      expect(dto.tripId, 'trip-001');
      expect(dto.assignedBoxesCount, 8);
      expect(dto.receivedBoxesCount, 8);
      expect(dto.canStartTrip, true);

      final entity = dto.toEntity();
      expect(entity.tripId, 'trip-001');
      expect(entity.tripCode, 'TRIP-101');
      expect(entity.assignedBoxesCount, 8);
      expect(entity.validatedBoxesCount, 8);
      expect(entity.receivedBoxesCount, 8);
      expect(entity.allBoxesPickedUp, true);
      expect(entity.canStartTrip, true);
      expect(entity.boxes.length, 1);

      final item = entity.boxes.first;
      expect(item.boxId, 'box-101');
      expect(item.boxCode, 'BOX-1256');
      expect(item.isReceived, true);
    });

    test('uses fallback counters and empty list for missing values', () {
      const emptyDto = DriverPickupSummaryResponseDto();
      final entity = emptyDto.toEntity();

      expect(entity.tripId, '');
      expect(entity.assignedBoxesCount, 0);
      expect(entity.receivedBoxesCount, 0);
      expect(entity.canStartTrip, false);
      expect(entity.boxes, isEmpty);
    });
  });

  group('DriverTripStartResponseDto & Mapper', () {
    const rawJson = {
      'tripId': 'trip-001',
      'tripCode': 'TRIP-101',
      'startedAtUtc': '2026-09-27T10:10:00Z',
      'status': 'TripStarted',
      'statusText': 'بدأت الرحلة بنجاح',
      'activeRouteId': 'route-001',
      'message': 'Trip started successfully',
    };

    test('parses exact start-trip JSON and maps to entity', () {
      final dto = DriverTripStartResponseDto.fromJson(rawJson);
      expect(dto.tripId, 'trip-001');
      expect(dto.activeRouteId, 'route-001');

      final entity = dto.toEntity();
      expect(entity.tripId, 'trip-001');
      expect(entity.tripCode, 'TRIP-101');
      expect(entity.activeRouteId, 'route-001');
      expect(entity.startedAtUtc, DateTime.parse('2026-09-27T10:10:00Z'));
    });
  });
}

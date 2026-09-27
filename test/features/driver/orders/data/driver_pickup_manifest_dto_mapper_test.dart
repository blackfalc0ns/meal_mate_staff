import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/mapper/driver_pickup_manifest_mapper.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_pickup_manifest_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_boxes_filter_type.dart';

void main() {
  group('DriverBoxesFilterType', () {
    test('exposes correct wire values', () {
      expect(DriverBoxesFilterType.all.wireValue, 'All');
      expect(DriverBoxesFilterType.pendingScan.wireValue, 'PendingScan');
      expect(DriverBoxesFilterType.pickedUp.wireValue, 'PickedUp');
    });
  });

  group('DriverPickupManifestResponseDto', () {
    const rawJson = {
      'tripId': 'trip-101',
      'tripCode': 'TRIP-101',
      'driverId': 'driver-501',
      'driverName': 'Ahmed Ali',
      'totalBoxesCount': 8,
      'totalMealsCount': 32,
      'pendingScanBoxesCount': 7,
      'pickedUpBoxesCount': 1,
      'scannedBoxesCount': 1,
      'allBoxesPickedUp': false,
      'canStartTrip': false,
      'boxes': [
        {
          'boxId': 'box-001',
          'boxCode': 'BOX-1256',
          'customerName': 'Khalid',
          'deliveryZone': 'حي النرجس',
          'mealsCount': 4,
          'mealsSummary': '4x Chicken Rice',
          'deliveryTimeSlot': '12:00 PM - 02:00 PM',
          'scanStatus': 'PendingScan',
          'scanStatusText': 'لم يتم التحميل',
          'isScanned': false,
          'scannedAtUtc': null,
          'conditionPhotoStorageKey': null,
        },
        {
          'boxId': 'box-002',
          'boxCode': 'BOX-1257',
          'customerName': 'Sara',
          'deliveryZone': 'حي الياسمين',
          'mealsCount': 3,
          'mealsSummary': '3x Salad Bowl',
          'deliveryTimeSlot': '01:00 PM - 03:00 PM',
          'scanStatus': 'PickedUp',
          'scanStatusText': 'تم التحميل',
          'isScanned': true,
          'scannedAtUtc': '2026-09-27T10:00:00Z',
          'conditionPhotoStorageKey': 'photos/box-002-photo.jpg',
        },
      ],
    };

    test('parses exact 06.02 JSON correctly', () {
      final dto = DriverPickupManifestResponseDto.fromJson(rawJson);

      expect(dto.tripId, 'trip-101');
      expect(dto.tripCode, 'TRIP-101');
      expect(dto.totalBoxesCount, 8);
      expect(dto.totalMealsCount, 32);
      expect(dto.pendingScanBoxesCount, 7);
      expect(dto.pickedUpBoxesCount, 1);
      expect(dto.scannedBoxesCount, 1);
      expect(dto.allBoxesPickedUp, false);
      expect(dto.canStartTrip, false);
      expect(dto.boxes?.length, 2);

      final box1 = dto.boxes!.first;
      expect(box1.boxId, 'box-001');
      expect(box1.boxCode, 'BOX-1256');
      expect(box1.scanStatus, 'PendingScan');
      expect(box1.isScanned, false);
      expect(box1.conditionPhotoStorageKey, isNull);

      final box2 = dto.boxes!.last;
      expect(box2.boxId, 'box-002');
      expect(box2.boxCode, 'BOX-1257');
      expect(box2.scanStatus, 'PickedUp');
      expect(box2.isScanned, true);
      expect(box2.conditionPhotoStorageKey, 'photos/box-002-photo.jpg');
    });

    test('handles missing and null fields defensively', () {
      final dto = DriverPickupManifestResponseDto.fromJson(const {});
      expect(dto.tripId, isNull);
      expect(dto.totalBoxesCount, isNull);
      expect(dto.boxes, isNull);
    });
  });

  group('DriverPickupManifestMapper', () {
    test('maps full DTO to canonical domain entity', () {
      const dto = DriverPickupManifestResponseDto(
        tripId: 'trip-101',
        tripCode: 'TRIP-101',
        driverId: 'driver-501',
        driverName: 'Ahmed Ali',
        totalBoxesCount: 8,
        totalMealsCount: 32,
        pendingScanBoxesCount: 7,
        pickedUpBoxesCount: 1,
        scannedBoxesCount: 1,
        allBoxesPickedUp: false,
        canStartTrip: false,
        boxes: [
          DriverAssignedBoxResponseDto(
            boxId: 'box-001',
            boxCode: 'BOX-1256',
            customerName: 'Khalid',
            deliveryZone: 'حي النرجس',
            mealsCount: 4,
            mealsSummary: '4x Chicken Rice',
            deliveryTimeSlot: '12:00 PM - 02:00 PM',
            scanStatus: 'PendingScan',
            scanStatusText: 'لم يتم التحميل',
            isScanned: false,
            scannedAtUtc: null,
            conditionPhotoStorageKey: null,
          ),
          DriverAssignedBoxResponseDto(
            boxId: 'box-002',
            boxCode: 'BOX-1257',
            customerName: 'Sara',
            deliveryZone: 'حي الياسمين',
            mealsCount: 3,
            mealsSummary: '3x Salad Bowl',
            deliveryTimeSlot: '01:00 PM - 03:00 PM',
            scanStatus: 'PickedUp',
            scanStatusText: 'تم التحميل',
            isScanned: true,
            scannedAtUtc: '2026-09-27T10:00:00Z',
            conditionPhotoStorageKey: 'photos/box-002-photo.jpg',
          ),
        ],
      );

      final entity = dto.toEntity();

      expect(entity.tripId, 'trip-101');
      expect(entity.tripCode, 'TRIP-101');
      expect(entity.totalBoxesCount, 8);
      expect(entity.totalMealsCount, 32);
      expect(entity.pendingScanBoxesCount, 7);
      expect(entity.pickedUpBoxesCount, 1);
      expect(entity.allBoxesPickedUp, false);
      expect(entity.canStartTrip, false);
      expect(entity.boxes.length, 2);

      expect(entity.boxes.first.status, DriverBoxDeliveryStatus.pendingScan);
      expect(entity.boxes.first.isPickedUp, isFalse);

      expect(entity.boxes.last.status, DriverBoxDeliveryStatus.pickedUp);
      expect(entity.boxes.last.isPickedUp, isTrue);
      expect(
        entity.boxes.last.conditionPhotoStorageKey,
        'photos/box-002-photo.jpg',
      );
    });

    test('uses fallback values for empty/null DTO', () {
      const emptyDto = DriverPickupManifestResponseDto();
      final entity = emptyDto.toEntity();

      expect(entity.tripId, '');
      expect(entity.tripCode, '');
      expect(entity.driverId, '');
      expect(entity.driverName, '');
      expect(entity.totalBoxesCount, 0);
      expect(entity.totalMealsCount, 0);
      expect(entity.pendingScanBoxesCount, 0);
      expect(entity.pickedUpBoxesCount, 0);
      expect(entity.allBoxesPickedUp, false);
      expect(entity.canStartTrip, false);
      expect(entity.boxes, isEmpty);
    });

    test('falls back to scannedBoxesCount if pickedUpBoxesCount is null', () {
      const legacyDto = DriverPickupManifestResponseDto(scannedBoxesCount: 3);
      final entity = legacyDto.toEntity();
      expect(entity.pickedUpBoxesCount, 3);
    });

    test('maps unknown status to pendingScan', () {
      const boxDto = DriverAssignedBoxResponseDto(
        boxId: 'box-999',
        scanStatus: 'UnknownStatus',
      );
      final boxEntity = boxDto.toEntity();
      expect(boxEntity.status, DriverBoxDeliveryStatus.pendingScan);
      expect(boxEntity.isPickedUp, isFalse);
    });
  });
}

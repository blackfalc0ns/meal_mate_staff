import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/mapper/driver_delivery_mapper.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_arrival_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_deliver_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_delivery_proof_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_request_entity.dart';

void main() {
  group('Driver Delivery DTO & Mapper Tests', () {
    test('serializes DriverArrivalRequestDto correctly and omits null coordinates', () {
      const entityWithNoCoords = DriverArrivalRequestEntity();
      final dtoNoCoords = entityWithNoCoords.toDto();
      expect(dtoNoCoords.toJson(), isEmpty);

      // Single coordinate should be omitted (Orders.CoordinatesPairRequired)
      const entitySingleCoord = DriverArrivalRequestEntity(latitude: 29.35);
      final dtoSingle = entitySingleCoord.toDto();
      expect(dtoSingle.toJson(), isEmpty);

      // Invalid range coordinate should be omitted
      const entityOutOfRange = DriverArrivalRequestEntity(latitude: 95.0, longitude: 48.0);
      final dtoOutOfRange = entityOutOfRange.toDto();
      expect(dtoOutOfRange.toJson(), isEmpty);

      // Valid coordinate pair included
      const entityValid = DriverArrivalRequestEntity(latitude: 29.35, longitude: 48.02);
      final dtoValid = entityValid.toDto();
      expect(dtoValid.toJson(), {
        'latitude': 29.35,
        'longitude': 48.02,
      });
    });

    test('serializes DriverDeliverRequestDto correctly and handles OTP & coords', () {
      const entity = DriverDeliverRequestEntity(
        proofPhotoStorageKey: 'uploads/drivers/delivery/test-key-123.jpg',
        latitude: 29.38,
        longitude: 47.98,
        deliveryOtp: '1234',
      );
      final dto = entity.toDto();
      final json = dto.toJson();
      expect(json['proofPhotoStorageKey'], 'uploads/drivers/delivery/test-key-123.jpg');
      expect(json['latitude'], 29.38);
      expect(json['longitude'], 47.98);
      expect(json['deliveryOtp'], '1234');
      expect(json.containsKey('localPath'), isFalse);

      // Incomplete OTP omitted
      const entityIncompleteOtp = DriverDeliverRequestEntity(
        proofPhotoStorageKey: 'key-123',
        deliveryOtp: '12',
      );
      final jsonIncomplete = entityIncompleteOtp.toDto().toJson();
      expect(jsonIncomplete.containsKey('deliveryOtp'), isFalse);
    });

    test('maps DriverArrivalResponseDto to entity correctly', () {
      final json = {
        'boxId': 'box-abc',
        'arrivedAtUtc': '2026-10-06T08:35:00Z',
        'isFirstArrival': true,
        'status': 'Arrived',
      };
      final dto = DriverArrivalResponseDto.fromJson(json);
      final entity = dto.toEntity(fallbackBoxId: 'fallback-box');

      expect(entity.boxId, 'box-abc');
      expect(entity.arrivedAtUtc, DateTime.utc(2026, 10, 6, 8, 35));
      expect(entity.isFirstArrival, isTrue);
      expect(entity.status, 'Arrived');
    });

    test('maps DriverDeliverResponseDto to entity correctly', () {
      final json = {
        'boxId': 'box-xyz',
        'deliveredAtUtc': '2026-10-06T08:45:00Z',
        'tripId': 'trip-1',
        'isTripCompleted': false,
        'remainingStopsCount': 2,
        'driverId': 'driver-9',
        'isFirstDelivery': true,
      };
      final dto = DriverDeliverResponseDto.fromJson(json);
      final entity = dto.toEntity(fallbackBoxId: 'fallback-box');

      expect(entity.boxId, 'box-xyz');
      expect(entity.deliveredAtUtc, DateTime.utc(2026, 10, 6, 8, 45));
      expect(entity.tripId, 'trip-1');
      expect(entity.isTripCompleted, isFalse);
      expect(entity.remainingStopsCount, 2);
      expect(entity.driverId, 'driver-9');
      expect(entity.isFirstDelivery, isTrue);
    });

    test('maps DriverDeliveryProofUploadResponseDto to entity', () {
      final json = {
        'storageKey': 'key-uploaded-456',
        'uploadedAtUtc': '2026-10-06T08:40:00Z',
      };
      final dto = DriverDeliveryProofUploadResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.storageKey, 'key-uploaded-456');
      expect(entity.uploadedAtUtc, DateTime.utc(2026, 10, 6, 8, 40));
    });
  });
}

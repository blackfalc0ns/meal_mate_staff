import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/request/update_driver_availability_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/dispatcher_drivers_status_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/update_driver_availability_response_dto.dart';

void main() {
  group('DispatcherDriversStatusResponseDto', () {
    test('parses full json response matching Screen 04.05 contract', () {
      final json = {
        'counts': {
          'total': 24,
          'available': 12,
          'inDelivery': 8,
          'unavailable': 4,
        },
        'items': [
          {
            'driverId': 'driver-1',
            'driverCode': 'DR-1025',
            'fullName': 'أحمد السعيد',
            'phoneNumber': '+96550123456',
            'avatarStorageKey': 'uploads/drivers/profiles/photo1.jpg',
            'isAvailable': true,
            'operationalStatus': 'Available',
            'rating': 4.8,
            'ratingsCount': 34,
            'vehicleType': 'Car',
            'vehicleModel': 'Toyota Corolla',
            'vehiclePlate': '12-3456',
          },
        ],
        'pagination': {
          'pageNumber': 1,
          'pageSize': 15,
          'totalItems': 24,
          'totalPages': 2,
          'hasPreviousPage': false,
          'hasNextPage': true,
        },
      };

      final dto = DispatcherDriversStatusResponseDto.fromJson(json);

      expect(dto.counts?.total, 24);
      expect(dto.counts?.available, 12);
      expect(dto.counts?.inDelivery, 8);
      expect(dto.counts?.unavailable, 4);

      expect(dto.items?.length, 1);
      final item = dto.items!.single;
      expect(item.driverId, 'driver-1');
      expect(item.driverCode, 'DR-1025');
      expect(item.fullName, 'أحمد السعيد');
      expect(item.phoneNumber, '+96550123456');
      expect(item.avatarStorageKey, 'uploads/drivers/profiles/photo1.jpg');
      expect(item.isAvailable, isTrue);
      expect(item.operationalStatus, 'Available');
      expect(item.rating, 4.8);
      expect(item.ratingsCount, 34);
      expect(item.vehicleType, 'Car');
      expect(item.vehicleModel, 'Toyota Corolla');
      expect(item.vehiclePlate, '12-3456');

      expect(dto.pagination?.pageNumber, 1);
      expect(dto.pagination?.pageSize, 15);
      expect(dto.pagination?.totalItems, 24);
      expect(dto.pagination?.totalPages, 2);
      expect(dto.pagination?.hasPreviousPage, isFalse);
      expect(dto.pagination?.hasNextPage, isTrue);
    });

    test('handles sparse response with all null fields defensibly', () {
      final json = <String, dynamic>{};
      final dto = DispatcherDriversStatusResponseDto.fromJson(json);

      expect(dto.counts, isNull);
      expect(dto.items, isNull);
      expect(dto.pagination, isNull);
    });

    test('parses numeric rating from int or double', () {
      final json = {
        'items': [
          {'driverId': 'd1', 'rating': 5},
          {'driverId': 'd2', 'rating': 4.5},
        ],
      };
      final dto = DispatcherDriversStatusResponseDto.fromJson(json);
      expect(dto.items?[0].rating, 5.0);
      expect(dto.items?[1].rating, 4.5);
    });
  });

  group('UpdateDriverAvailabilityRequestDto', () {
    test('serializes Inactive shiftStatus and omits reason', () {
      const dto = UpdateDriverAvailabilityRequestDto(
        isAvailable: false,
        reason: 'استراحة غداء مجدولة',
      );
      final json = dto.toJson();
      expect(json, {'shiftStatus': 'Inactive'});
    });

    test('omits reason when null', () {
      const dto = UpdateDriverAvailabilityRequestDto(isAvailable: true);
      final json = dto.toJson();
      expect(json, {'shiftStatus': 'Active'});
      expect(json.containsKey('reason'), isFalse);
    });
  });

  group('UpdateDriverAvailabilityResponseDto', () {
    test('parses full patch response', () {
      final json = {
        'driverId': 'driver-1',
        'isAvailable': true,
        'operationalStatus': 'Available',
        'updatedAtUtc': '2026-09-27T14:30:00Z',
      };
      final dto = UpdateDriverAvailabilityResponseDto.fromJson(json);
      expect(dto.driverId, 'driver-1');
      expect(dto.isAvailable, isTrue);
      expect(dto.operationalStatus, 'Available');
      expect(dto.updatedAtUtc, '2026-09-27T14:30:00Z');
    });

    test('parses sparse response defensibly', () {
      final dto = UpdateDriverAvailabilityResponseDto.fromJson({});
      expect(dto.driverId, isNull);
      expect(dto.isAvailable, isNull);
      expect(dto.operationalStatus, isNull);
      expect(dto.updatedAtUtc, isNull);
    });
  });
}

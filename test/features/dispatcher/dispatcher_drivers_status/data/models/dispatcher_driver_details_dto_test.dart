import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/dispatcher_driver_details_response_dto.dart';

void main() {
  group('DispatcherDriverDetailsResponseDto', () {
    test('parses full json response matching Screen 04.07 contract', () {
      final json = {
        'driver': {
          'driverId': '4a6f235e-c04d-45db-9c3f-c39775c96da1',
          'driverCode': '#KD-4582',
          'fullName': 'أحمد محمد',
          'phoneNumber': '+965 5012 3456',
          'avatarStorageKey': 'uploads/drivers/profiles/photo1.jpg',
          'isAvailable': true,
          'operationalStatus': 'Available',
          'rating': 4.8,
          'ratingsCount': 128,
        },
        'today': {
          'completedDeliveries': 38,
          'activeDeliveries': 5,
          'cashCollected': 142.50,
          'distanceKm': 42.6,
        },
        'vehicle': {
          'vehicleType': 'Car',
          'vehicleModel': 'تويوتا كورولا',
          'vehiclePlate': '#KU-7319',
          'color': 'أبيض',
        },
        'currentLocation': {
          'latitude': 29.3375,
          'longitude': 48.0261,
          'address': 'المنطقة السالمية',
          'updatedAtUtc': '2026-09-27T14:28:00Z',
        },
        'performance': {
          'acceptanceRate': 98.0,
          'onTimeRate': 95.5,
          'averageDeliveryMinutes': 22,
          'totalDeliveries': 412,
        },
        'documents': [
          {
            'documentType': 'driving_license',
            'documentName': 'رخصة القيادة',
            'status': 'Valid',
            'expiryDate': '2027-05-15',
            'documentUrl': 'https://example.com/docs/license.pdf',
          },
          {
            'documentType': 'vehicle_registration',
            'documentName': 'دفتر المركبة',
            'status': 'ExpiringSoon',
            'expiryDate': '2026-10-01',
            'documentUrl': 'https://example.com/docs/reg.pdf',
          },
        ],
      };

      final dto = DispatcherDriverDetailsResponseDto.fromJson(json);

      expect(dto.driver?.driverId, '4a6f235e-c04d-45db-9c3f-c39775c96da1');
      expect(dto.driver?.driverCode, '#KD-4582');
      expect(dto.driver?.fullName, 'أحمد محمد');
      expect(dto.driver?.phoneNumber, '+965 5012 3456');
      expect(
        dto.driver?.avatarStorageKey,
        'uploads/drivers/profiles/photo1.jpg',
      );
      expect(dto.driver?.isAvailable, isTrue);
      expect(dto.driver?.operationalStatus, 'Available');
      expect(dto.driver?.rating, 4.8);
      expect(dto.driver?.ratingsCount, 128);

      expect(dto.today?.completedDeliveries, 38);
      expect(dto.today?.activeDeliveries, 5);
      expect(dto.today?.cashCollected, 142.50);
      expect(dto.today?.distanceKm, 42.6);

      expect(dto.vehicle?.vehicleType, 'Car');
      expect(dto.vehicle?.vehicleModel, 'تويوتا كورولا');
      expect(dto.vehicle?.vehiclePlate, '#KU-7319');
      expect(dto.vehicle?.color, 'أبيض');

      expect(dto.currentLocation?.latitude, 29.3375);
      expect(dto.currentLocation?.longitude, 48.0261);
      expect(dto.currentLocation?.address, 'المنطقة السالمية');
      expect(dto.currentLocation?.updatedAtUtc, '2026-09-27T14:28:00Z');

      expect(dto.performance?.acceptanceRate, 98.0);
      expect(dto.performance?.onTimeRate, 95.5);
      expect(dto.performance?.averageDeliveryMinutes, 22);
      expect(dto.performance?.totalDeliveries, 412);

      expect(dto.documents?.length, 2);
      expect(dto.documents?[0].documentType, 'driving_license');
      expect(dto.documents?[0].status, 'Valid');
      expect(dto.documents?[1].status, 'ExpiringSoon');
    });

    test('parses sparse details response without throwing', () {
      final dto = DispatcherDriverDetailsResponseDto.fromJson({});
      expect(dto.driver, isNull);
      expect(dto.today, isNull);
      expect(dto.vehicle, isNull);
      expect(dto.currentLocation, isNull);
      expect(dto.performance, isNull);
      expect(dto.documents, isNull);
    });

    test('coerces ints to doubles for numeric fields', () {
      final json = {
        'driver': {'rating': 4},
        'today': {'cashCollected': 150, 'distanceKm': 40},
        'currentLocation': {'latitude': 29, 'longitude': 48},
        'performance': {'acceptanceRate': 100, 'onTimeRate': 90},
      };

      final dto = DispatcherDriverDetailsResponseDto.fromJson(json);
      expect(dto.driver?.rating, 4.0);
      expect(dto.today?.cashCollected, 150.0);
      expect(dto.today?.distanceKm, 40.0);
      expect(dto.currentLocation?.latitude, 29.0);
      expect(dto.currentLocation?.longitude, 48.0);
      expect(dto.performance?.acceptanceRate, 100.0);
      expect(dto.performance?.onTimeRate, 90.0);
    });
  });
}

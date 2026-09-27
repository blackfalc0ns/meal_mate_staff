import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/mapper/dispatcher_driver_details_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/dispatcher_driver_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_document_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';

void main() {
  group('DispatcherDriverDetailsMapper', () {
    const baseUrl = 'http://maelmate.runasp.net';

    test('maps full details response correctly', () {
      const dto = DispatcherDriverDetailsResponseDto(
        driver: DispatcherDriverDetailsProfileDto(
          driverId: 'd-1',
          driverCode: 'DR-101',
          fullName: 'أحمد محمد',
          phoneNumber: '+965 5012 3456',
          avatarStorageKey: 'uploads/photo.jpg',
          isAvailable: true,
          operationalStatus: 'Available',
          rating: 4.8,
          ratingsCount: 128,
        ),
        today: DispatcherDriverDetailsTodayDto(
          completedDeliveries: 38,
          activeDeliveries: 5,
          cashCollected: 142.50,
          distanceKm: 42.6,
        ),
        vehicle: DispatcherDriverDetailsVehicleDto(
          vehicleType: 'Car',
          vehicleModel: 'تويوتا كورولا',
          vehiclePlate: '#KU-7319',
          color: 'أبيض',
        ),
        currentLocation: DispatcherDriverDetailsLocationDto(
          latitude: 29.3375,
          longitude: 48.0261,
          address: 'السالمية',
          updatedAtUtc: '2026-09-27T14:28:00Z',
        ),
        performance: DispatcherDriverDetailsPerformanceDto(
          acceptanceRate: 98.0,
          onTimeRate: 95.5,
          averageDeliveryMinutes: 22,
          totalDeliveries: 412,
        ),
        documents: [
          DispatcherDriverDetailsDocumentDto(
            documentType: 'driving_license',
            documentName: 'رخصة القيادة',
            status: 'Valid',
            expiryDate: '2027-05-15',
            documentUrl: 'https://example.com/license.pdf',
          ),
          DispatcherDriverDetailsDocumentDto(
            documentType: 'vehicle_registration',
            documentName: 'دفتر المركبة',
            status: 'ExpiringSoon',
            expiryDate: '2026-10-01',
          ),
          DispatcherDriverDetailsDocumentDto(
            documentType: 'insurance',
            documentName: 'التأمين',
            status: 'Expired',
            expiryDate: '2025-01-01',
          ),
          DispatcherDriverDetailsDocumentDto(
            documentType: 'civil_id',
            documentName: 'البطاقة المدنية',
            status: null,
            expiryDate: null,
          ),
        ],
      );

      final entity = DispatcherDriverDetailsMapper.toEntity(
        dto,
        baseUrl: baseUrl,
      );

      expect(entity.id, 'd-1');
      expect(entity.name, 'أحمد محمد');
      expect(entity.code, 'DR-101');
      expect(entity.phoneNumber, '+965 5012 3456');
      expect(entity.avatarUrl, 'http://maelmate.runasp.net/uploads/photo.jpg');
      expect(entity.isAvailable, isTrue);
      expect(entity.operationalStatus, DispatcherDriverStatusType.available);
      expect(entity.isOnline, isTrue);
      expect(entity.rating, 4.8);
      expect(entity.reviewCount, 128);

      expect(entity.totalOrdersToday, 38);
      expect(entity.activeOrdersToday, 5);
      expect(entity.cashCollectedToday, 142.50);
      expect(entity.distanceKmToday, 42.6);

      expect(entity.vehicle?.model, 'تويوتا كورولا');
      expect(entity.vehicle?.plateNumber, '#KU-7319');
      expect(entity.vehicle?.colorName, 'أبيض');
      expect(entity.vehicle?.vehicleType, 'Car');

      expect(entity.location?.latitude, 29.3375);
      expect(entity.location?.longitude, 48.0261);
      expect(entity.location?.areaName, 'السالمية');
      expect(entity.location?.hasCoordinates, isTrue);

      expect(entity.performance?.commitmentRatePercent, 98);
      expect(entity.performance?.averageRating, 4.8);
      expect(entity.performance?.totalOrders, 412);

      expect(entity.documents.length, 4);
      expect(entity.documents[0].status, DispatcherDriverDocumentStatus.valid);
      expect(entity.documents[0].isValid, isTrue);
      expect(
        entity.documents[1].status,
        DispatcherDriverDocumentStatus.expiringSoon,
      );
      expect(entity.documents[1].isValid, isTrue);
      expect(
        entity.documents[2].status,
        DispatcherDriverDocumentStatus.expired,
      );
      expect(entity.documents[2].isValid, isFalse);
      expect(
        entity.documents[3].status,
        DispatcherDriverDocumentStatus.missing,
      );
      expect(entity.documents[3].isValid, isFalse);
    });

    test('maps sparse details response with nulls gracefully', () {
      const dto = DispatcherDriverDetailsResponseDto();
      final entity = DispatcherDriverDetailsMapper.toEntity(
        dto,
        fallbackDriverId: 'd-fallback',
      );

      expect(entity.id, 'd-fallback');
      expect(entity.name, '');
      expect(entity.phoneNumber, isNull);
      expect(entity.avatarUrl, isNull);
      expect(entity.rating, isNull);
      expect(entity.reviewCount, isNull);
      expect(entity.vehicle, isNull);
      expect(entity.location, isNull);
      expect(entity.performance, isNull);
      expect(entity.documents, isEmpty);
    });
  });
}

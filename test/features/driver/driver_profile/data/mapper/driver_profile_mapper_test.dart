import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/data/mapper/driver_profile_mapper.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/data/models/response/driver_profile_response_dto.dart';

void main() {
  group('DriverProfileMapper', () {
    test('preserves meaningful absence and valid zero counts', () {
      final entity = const DriverProfileResponseDto(
        fullName: 'Ahmed',
        reviewsCount: 0,
        totalOrders: 0,
        averageRating: null,
        acceptanceRatePercent: null,
        documents: [],
      ).toEntity();
      expect(entity.reviewsCount, 0);
      expect(entity.totalOrders, 0);
      expect(entity.averageRating, isNull);
      expect(entity.acceptanceRatePercent, isNull);
      expect(entity.documents, isEmpty);
    });

    test('parses UTC instants but preserves expiryDate as a date string', () {
      final entity = DriverProfileResponseDto.fromJson({
        'joinedAtUtc': '2026-01-10T08:30:00Z',
        'documents': [
          {'expiryDate': '2027-11-15'},
        ],
      }).toEntity();
      expect(entity.joinedAtUtc?.isUtc, isTrue);
      expect(entity.documents.single.expiryDate, '2027-11-15');
    });

    test('maps all nested entities accurately', () {
      final entity = DriverProfileResponseDto.fromJson({
        'driverProfileId': 'dp-1',
        'fullName': 'محمود علي',
        'driverDescription': 'سائق ممتاز',
        'driverRank': 'Gold',
        'driverCode': 'DRV99',
        'phoneNumber': '+201012345678',
        'profileImageUrl': 'https://example.com/avatar.jpg',
        'isOnline': true,
        'status': 'Online',
        'statusText': 'متصل الآن',
        'averageRating': 4.8,
        'reviewsCount': 120,
        'totalOrders': 450,
        'acceptanceRatePercent': 98.5,
        'joinedAtUtc': '2025-05-20T10:00:00Z',
        'vehicle': {
          'vehicleType': 'Car',
          'vehicleModel': 'Toyota Corolla',
          'vehicleYear': 2023,
          'vehicleColor': 'Silver',
          'plateNumber': '5678 XYZ',
          'plateGovernorate': 'Giza',
          'verificationStatus': 'Verified',
          'verificationStatusText': 'تم التحقق',
          'isVehicleActive': true,
        },
        'documents': [
          {
            'documentId': 'doc-1',
            'documentType': 'License',
            'documentTitle': 'رخصة القيادة',
            'status': 'Approved',
            'statusText': 'سارية',
            'expiryDate': '2028-01-01',
            'daysUntilExpiry': 500,
          }
        ],
        'assignment': {
          'restaurantId': 'r-1',
          'restaurantName': 'برجر كينج',
          'branchId': 'b-1',
          'branchName': 'مدينة نصر',
        },
        'latestSupportTicket': {
          'ticketId': 't-1',
          'ticketNumber': '#12345',
          'subject': 'تأخر استلام الطلب',
          'body': 'تفاصيل الشكوى',
          'status': 'Resolved',
          'statusText': 'تم الحل',
          'priority': 'Low',
          'priorityText': 'منخفضة',
          'createdAtUtc': '2026-01-15T14:30:00Z',
        },
      }).toEntity();

      expect(entity.driverProfileId, 'dp-1');
      expect(entity.fullName, 'محمود علي');
      expect(entity.driverRank, 'Gold');
      expect(entity.vehicle?.vehicleModel, 'Toyota Corolla');
      expect(entity.vehicle?.color, 'Silver');
      expect(entity.vehicle?.plateGovernorate, 'Giza');
      expect(entity.documents.first.documentTitle, 'رخصة القيادة');
      expect(entity.assignment?.restaurantName, 'برجر كينج');
      expect(entity.assignment?.branchName, 'مدينة نصر');
      expect(entity.latestSupportTicket?.ticketNumber, '#12345');
      expect(entity.latestSupportTicket?.createdAtUtc?.isUtc, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/data/models/response/driver_profile_response_dto.dart';

void main() {
  group('DriverProfileResponseDto', () {
    test('parses full direct response and accepts integer numeric doubles', () {
      final dto = DriverProfileResponseDto.fromJson({
        'driverProfileId': 'profile-1',
        'fullName': 'أحمد إبراهيم',
        'driverDescription': 'كابتن توصيل معتمد',
        'driverCode': 'profile1',
        'isOnline': true,
        'status': 'Online',
        'statusText': 'متصل',
        'averageRating': 5,
        'reviewsCount': 0,
        'totalOrders': 0,
        'acceptanceRatePercent': null,
        'joinedAtUtc': '2026-01-10T08:30:00Z',
        'vehicle': {'vehicleYear': 2024, 'vehicleModel': null},
        'documents': <Map<String, dynamic>>[],
        'assignment': null,
        'latestSupportTicket': null,
      });
      expect(dto.averageRating, 5);
      expect(dto.reviewsCount, 0);
      expect(dto.documents, isEmpty);
      expect(dto.assignment, isNull);
    });

    test('does not throw when optional and nested fields are absent', () {
      expect(
        () => DriverProfileResponseDto.fromJson(const {}),
        returnsNormally,
      );
    });

    test('parses nested vehicle, documents, assignment, and ticket', () {
      final dto = DriverProfileResponseDto.fromJson({
        'driverProfileId': 'p-1',
        'vehicle': {
          'vehicleType': 'Motorcycle',
          'vehicleModel': 'Honda 2024',
          'vehicleYear': 2024,
          'vehicleColor': '#FF0000',
          'plateNumber': '1234 ABC',
          'plateGovernorate': 'Cairo',
          'verificationStatus': 'Approved',
          'verificationStatusText': 'موثقة',
          'isVehicleActive': true,
        },
        'documents': [
          {
            'documentId': 'doc-1',
            'documentType': 'DrivingLicense',
            'documentTitle': 'رخصة القيادة',
            'status': 'Approved',
            'statusText': 'معتمد',
            'expiryDate': '2027-11-15',
            'daysUntilExpiry': 400,
          },
        ],
        'assignment': {
          'restaurantId': 'rest-1',
          'restaurantName': 'مطعم البركة',
          'branchId': 'branch-1',
          'branchName': 'فرع المعادي',
        },
        'latestSupportTicket': {
          'ticketId': 'tick-1',
          'ticketNumber': '#SUP-100',
          'subject': 'مشكلة في التوصيل',
          'body': 'التفاصيل هنا',
          'status': 'Open',
          'statusText': 'قيد المعالجة',
          'priority': 'High',
          'priorityText': 'عالية',
          'createdAtUtc': '2026-02-01T12:00:00Z',
        },
      });

      expect(dto.vehicle?.vehicleModel, 'Honda 2024');
      expect(dto.vehicle?.vehicleYear, 2024);
      expect(dto.vehicle?.plateGovernorate, 'Cairo');
      expect(dto.documents?.length, 1);
      expect(dto.documents?.first.expiryDate, '2027-11-15');
      expect(dto.assignment?.restaurantName, 'مطعم البركة');
      expect(dto.latestSupportTicket?.ticketNumber, '#SUP-100');
    });
  });
}

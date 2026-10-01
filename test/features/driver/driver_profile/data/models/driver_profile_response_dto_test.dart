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

    test('parses live runasp backend payload accurately', () {
      final json = {
        "driverProfileId": "52a408f2-94d4-4c7d-bfaf-3e9017eb0d49",
        "fullNameAr": "يحيي سواق",
        "fullName": "يحيي سواق",
        "phoneNumber": "1236907854",
        "driverCode": "52a408f294d44c7dbfaf3e9017eb0d49",
        "profileImageStorageKey":
            "uploads/drivers/driver-registration/f53d8f92a4bb43c28c3aedeb8f4c10fa_Screenshot_2026-09-09-18-40-55-34_ffecf901ff8b6ced2230e4c65e7fd945.jpg",
        "profileImageUrl":
            "C:\\Windows\\TEMP\\mealmate-uploads\\uploads\\drivers\\driver-registration\\f53d8f92a4bb43c28c3aedeb8f4c10fa_Screenshot_2026-09-09-18-40-55-34_ffecf901ff8b6ced2230e4c65e7fd945.jpg",
        "isOnline": false,
        "status": "Offline",
        "statusText": "غير متصل",
        "averageRating": null,
        "reviewsCount": 0,
        "totalOrders": 0,
        "acceptanceRatePercent": null,
        "joinedAtUtc": "2026-09-30T22:46:44.790612Z",
        "driverRank": null,
        "driverDescription": "سائق توصيل معتمد",
        "vehicle": {
          "vehicleType": "Car",
          "vehicleTypeLocalized": "سيارة",
          "vehicleModel": "Honda Civic",
          "vehiclePlate": "1275765",
          "plateGovernorate": null,
          "vehicleYear": 2024,
          "vehicleColor": "#FFFFFF",
          "vehicleColorLocalized": "أبيض",
          "verificationStatus": "Approved",
          "verificationStatusText": "معتمد"
        },
        "documents": [
          {
            "documentId": "139fce1c-c761-4cfa-8a22-b4b01879b6c2",
            "documentType": "DrivingLicenseBack",
            "documentTitle": "رخصة القيادة - الوجه الخلفي",
            "status": "Approved",
            "statusText": "معتمد",
            "verificationStatus": "Approved",
            "expiryDate": "2027-10-04",
            "daysUntilExpiry": 368,
            "requiresRenewal": false
          }
        ],
        "assignment": {
          "restaurantId": "f8575d1f-943e-455b-bd45-12b5af4eb097",
          "restaurantName": "[تجربة] مطبخ دايت كير",
          "branchId": null,
          "branchName": null
        },
        "latestSupportTicket": null
      };

      final dto = DriverProfileResponseDto.fromJson(json);
      expect(dto.fullNameAr, "يحيي سواق");
      expect(dto.vehicle?.effectivePlate, "1275765");
      expect(dto.vehicle?.effectiveTypeLocalized, "سيارة");
      expect(dto.vehicle?.effectiveColorLocalized, "أبيض");
      expect(dto.documents?.first.verificationStatus, "Approved");
      expect(dto.documents?.first.requiresRenewal, false);
      expect(dto.assignment?.restaurantName, "[تجربة] مطبخ دايت كير");
    });
  });
}

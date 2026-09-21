import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/register/data/mapper/driver_registration_mapper.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_registration_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_resubmit_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_file_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_registration_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_restaurant_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_nationality_response_dto.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_draft_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_resubmit_entity.dart';

void main() {
  group('Driver Registration DTO and Serialization Tests', () {
    test('DriverNationalityResponseDto preserves the backend contract', () {
      final dto = DriverNationalityResponseDto.fromJson(const {
        'code': 'KW',
        'name': 'كويتي',
        'nameAr': 'كويتي',
        'nameEn': 'Kuwaiti',
        'countryName': 'الكويت',
        'countryNameAr': 'الكويت',
        'countryNameEn': 'Kuwait',
        'flagEmoji': '🇰🇼',
      });
      expect(dto.code, 'KW');
      expect(dto.nameEn, 'Kuwaiti');
      expect(dto.flagEmoji, '🇰🇼');
    });
    test(
      'DriverRestaurantResponseDto handles full JSON, nulls, and empty map',
      () {
        final json = {
          'id': 'res-123',
          'tradeName': 'Balance Box',
          'tradeNameAr': 'بالانس بوكس',
          'tradeNameEn': 'Balance Box',
          'logoUrl': 'https://example.com/logo.png',
          'contactPhone': '+96550001006',
        };

        final dto = DriverRestaurantResponseDto.fromJson(json);
        expect(dto.id, 'res-123');
        expect(dto.tradeName, 'Balance Box');
        expect(dto.tradeNameAr, 'بالانس بوكس');
        expect(dto.tradeNameEn, 'Balance Box');
        expect(dto.logoUrl, 'https://example.com/logo.png');
        expect(dto.contactPhone, '+96550001006');

        final emptyDto = DriverRestaurantResponseDto.fromJson({});
        expect(emptyDto.id, isNull);
        expect(emptyDto.tradeName, isNull);
        expect(emptyDto.tradeNameAr, isNull);
      },
    );

    test('DriverFileUploadResponseDto handles full JSON and nulls', () {
      final json = {
        'storageKey': 'https://ik.imagekit.io/.../doc_xyz.png',
        'readUrl': 'https://ik.imagekit.io/.../doc_xyz.png',
        'fileName': 'doc.png',
        'contentType': 'image/png',
        'sizeBytes': 1048576,
      };

      final dto = DriverFileUploadResponseDto.fromJson(json);
      expect(dto.storageKey, 'https://ik.imagekit.io/.../doc_xyz.png');
      expect(dto.readUrl, 'https://ik.imagekit.io/.../doc_xyz.png');
      expect(dto.fileName, 'doc.png');
      expect(dto.contentType, 'image/png');
      expect(dto.sizeBytes, 1048576);

      final emptyDto = DriverFileUploadResponseDto.fromJson({});
      expect(emptyDto.storageKey, isNull);
      expect(emptyDto.sizeBytes, isNull);
    });

    test('DriverRegistrationResponseDto handles full JSON and nulls', () {
      final json = {
        'registrationId': 'reg-456',
        'restaurantId': 'res-123',
        'restaurantName': 'Balance Box',
        'phone': '+966501234567',
        'status': 'Submitted',
        'message': 'Registration submitted successfully.',
      };

      final dto = DriverRegistrationResponseDto.fromJson(json);
      expect(dto.registrationId, 'reg-456');
      expect(dto.restaurantId, 'res-123');
      expect(dto.restaurantName, 'Balance Box');
      expect(dto.phone, '+966501234567');
      expect(dto.status, 'Submitted');
      expect(dto.message, 'Registration submitted successfully.');

      final emptyDto = DriverRegistrationResponseDto.fromJson({});
      expect(emptyDto.registrationId, isNull);
      expect(emptyDto.status, isNull);
    });

    test(
      'DriverRegistrationRequestDto serializes to JSON according to contract',
      () {
        const dto = DriverRegistrationRequestDto(
          restaurantId: 'res-1',
          fullNameAr: 'أحمد الشمري',
          fullNameEn: 'Ahmed Al-Shammari',
          phone: '+966501234567',
          email: null,
          nationalId: '1098765432',
          nationalIdExpiry: '2029-01-01T00:00:00Z',
          dateOfBirth: '1994-05-20T00:00:00Z',
          nationality: 'Saudi',
          vehicleType: 'Car',
          vehicleModel: 'Toyota Camry',
          vehiclePlate: 'ABC1234',
          vehicleYear: 2023,
          vehicleColor: 'Silver',
          isVehicleOwned: true,
          licenseNumber: 'LIC987654',
          licenseExpiry: '2029-06-01T00:00:00Z',
          vehicleLicenseExpiry: '2028-12-01T00:00:00Z',
          contractExpiry: null,
          nationalIdFrontStorageKey: 'https://ik.imagekit.io/.../nid_front.png',
          nationalIdBackStorageKey: 'https://ik.imagekit.io/.../nid_back.png',
          drivingLicenseFrontStorageKey:
              'https://ik.imagekit.io/.../lic_front.png',
          drivingLicenseBackStorageKey:
              'https://ik.imagekit.io/.../lic_back.png',
          vehicleRegistrationStorageKey:
              'https://ik.imagekit.io/.../veh_reg.png',
          profileImageStorageKey: null,
          vehiclePhotoStorageKey: null,
          contractStorageKey: null,
        );

        final json = dto.toJson();
        expect(json['restaurantId'], 'res-1');
        expect(json['fullNameAr'], 'أحمد الشمري');
        expect(json['email'], isNull);
        expect(
          json['nationalIdFrontStorageKey'],
          'https://ik.imagekit.io/.../nid_front.png',
        );
        expect(json['isVehicleOwned'], isTrue);
        expect(json['vehicleYear'], 2023);
      },
    );

    test('DriverResubmitRequestDto omits nulls when serialized', () {
      const dto = DriverResubmitRequestDto(
        drivingLicenseFrontStorageKey: 'new-front-key',
        vehicleLicenseExpiry: '2029-12-01T00:00:00Z',
      );

      final json = dto.toJson();
      expect(json['drivingLicenseFrontStorageKey'], 'new-front-key');
      expect(json['vehicleLicenseExpiry'], '2029-12-01T00:00:00Z');
      expect(json.containsKey('fullNameAr'), isFalse);
      expect(json.containsKey('nationalId'), isFalse);
    });
  });

  group('Driver Registration Mappers Tests', () {
    test(
      'DriverRestaurantResponseDto maps defensively to DriverRestaurantEntity',
      () {
        const completeDto = DriverRestaurantResponseDto(
          id: 'res-1',
          tradeName: 'Burger King',
          tradeNameAr: 'برجر كنج',
          tradeNameEn: 'Burger King',
          logoUrl: 'logo.png',
          contactPhone: '123456',
        );
        final entity = completeDto.toEntity();
        expect(entity.id, 'res-1');
        expect(entity.tradeName, 'Burger King');
        expect(entity.tradeNameAr, 'برجر كنج');
        expect(entity.tradeNameEn, 'Burger King');

        const nullDto = DriverRestaurantResponseDto();
        final nullEntity = nullDto.toEntity();
        expect(nullEntity.id, '');
        expect(nullEntity.tradeName, '');
        expect(nullEntity.tradeNameAr, '');
        expect(nullEntity.tradeNameEn, '');
        expect(nullEntity.logoUrl, isNull);
      },
    );

    test(
      'DriverFileUploadResponseDto maps to DriverFileUploadResultEntity',
      () {
        const dto = DriverFileUploadResponseDto(
          storageKey: 'key-123',
          readUrl: 'url-123',
          fileName: 'file.jpg',
          contentType: 'image/jpeg',
          sizeBytes: 2048,
        );
        final entity = dto.toEntity();
        expect(entity.storageKey, 'key-123');
        expect(entity.readUrl, 'url-123');
        expect(entity.fileName, 'file.jpg');
        expect(entity.contentType, 'image/jpeg');
        expect(entity.sizeBytes, 2048);
      },
    );

    test(
      'DriverRegistrationDraftEntity maps correctly to DriverRegistrationRequestDto',
      () {
        const draft = DriverRegistrationDraftEntity(
          restaurantId: 'res-99',
          fullNameAr: 'سائق تجريبي',
          fullNameEn: 'Test Driver',
          phone: '+966555555555',
          email: '  test@driver.com  ',
          nationalId: '9876543210',
          nationalIdExpiry: '2030-01-01T00:00:00Z',
          dateOfBirth: '2000/01/01',
          nationality: 'Saudi',
          vehicleType: 'Motorcycle',
          vehicleModel: 'Honda',
          vehiclePlate: 'XYZ999',
          vehicleYear: 2022,
          vehicleColor: 'Black',
          isVehicleOwned: false,
          licenseNumber: 'L1234',
          licenseExpiry: '2028-01-01T00:00:00Z',
          vehicleLicenseExpiry: '2027-01-01T00:00:00Z',
          nationalIdFrontStorageKey: 'nid-f-key',
          nationalIdBackStorageKey: 'nid-b-key',
          drivingLicenseFrontStorageKey: 'lic-f-key',
          drivingLicenseBackStorageKey: 'lic-b-key',
          vehicleRegistrationStorageKey: 'veh-reg-key',
        );

        expect(draft.isReadyForSubmission, isTrue);

        final dto = draft.toDto();
        expect(dto.restaurantId, 'res-99');
        expect(dto.fullNameAr, 'سائق تجريبي');
        expect(dto.email, 'test@driver.com'); // Trimmed
        expect(dto.dateOfBirth, '2000-01-01');
        expect(dto.nationalIdFrontStorageKey, 'nid-f-key');
        expect(dto.vehicleType, 'Motorcycle');
        expect(dto.isVehicleOwned, isFalse);
        expect(dto.profileImageStorageKey, isNull);
      },
    );

    test('DriverRegistrationDraftEntity checks validation accurately', () {
      const emptyDraft = DriverRegistrationDraftEntity();
      expect(emptyDraft.hasRequiredPersonalData, isFalse);
      expect(emptyDraft.hasRequiredVehicleData, isFalse);
      expect(emptyDraft.hasRequiredDocuments, isFalse);
      expect(emptyDraft.isReadyForSubmission, isFalse);
    });

    test('DriverResubmitEntity maps correctly to DriverResubmitRequestDto', () {
      const entity = DriverResubmitEntity(
        drivingLicenseFrontStorageKey: 'updated-front-key',
        vehicleLicenseExpiry: '2031-01-01T00:00:00Z',
      );

      final dto = entity.toDto();
      expect(dto.drivingLicenseFrontStorageKey, 'updated-front-key');
      expect(dto.vehicleLicenseExpiry, '2031-01-01T00:00:00Z');
      expect(dto.fullNameAr, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/phone_lookup_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_auth_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_message_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/verify_first_time_otp_response_dto.dart';

void main() {
  group('Auth DTO Defensive Serialization Tests', () {
    test(
      'PhoneLookupResponseDto handles complete JSON, nulls, and empty map',
      () {
        final completeJson = {
          'exists': true,
          'isFirstTimeSetup': false,
          'role': 'Driver',
          'phone': '+966501234567',
          'fullName': 'Ahmed',
          'restaurantName': 'Balance Box',
          'restaurantId': 'res-1',
          'status': 'Submitted',
          'applicationStatus': {
            'registrationId': 'reg-1',
            'stage': 1,
            'badge': 'قيد المراجعة',
            'title': 'قيد المراجعة',
            'subtitle': 'تفاصيل',
            'notice': 'ملاحظة',
            'canResubmit': false,
            'isApproved': false,
            'restaurantApprovalStatus': 'Submitted',
            'adminApprovalStatus': 'Submitted',
            'changeRequestNotes': null,
            'rejectionReason': null,
          },
        };

        final dto = PhoneLookupResponseDto.fromJson(completeJson);
        expect(dto.exists, isTrue);
        expect(dto.isFirstTimeSetup, isFalse);
        expect(dto.role, 'Driver');
        expect(dto.applicationStatus?.stage, 1);
        expect(dto.applicationStatus?.canResubmit, isFalse);

        // Null / Empty Map
        final emptyDto = PhoneLookupResponseDto.fromJson({});
        expect(emptyDto.exists, isNull);
        expect(emptyDto.isFirstTimeSetup, isNull);
        expect(emptyDto.role, isNull);
        expect(emptyDto.applicationStatus, isNull);

        // Explicit nulls
        final nullJson = {
          'exists': null,
          'isFirstTimeSetup': null,
          'role': null,
          'phone': null,
          'applicationStatus': null,
        };
        final nullDto = PhoneLookupResponseDto.fromJson(nullJson);
        expect(nullDto.exists, isNull);
        expect(nullDto.applicationStatus, isNull);
      },
    );

    test(
      'StaffAuthResponseDto handles complete JSON, nulls, and empty map',
      () {
        final completeJson = {
          'userId': 'u-1',
          'phoneNumber': '+966501234567',
          'fullName': 'Driver Name',
          'userType': 'Driver',
          'accountStatus': 'Active',
          'restaurantId': 'res-1',
          'roles': ['Driver'],
          'accessToken': 'jwt.token.access',
          'refreshToken': 'jwt.token.refresh',
          'accessTokenExpiresAtUtc': '2026-09-20T11:00:00Z',
          'isAuthenticated': true,
        };

        final dto = StaffAuthResponseDto.fromJson(completeJson);
        expect(dto.userId, 'u-1');
        expect(dto.roles, ['Driver']);
        expect(dto.accessToken, 'jwt.token.access');
        expect(dto.isAuthenticated, isTrue);

        final emptyDto = StaffAuthResponseDto.fromJson({});
        expect(emptyDto.userId, isNull);
        expect(emptyDto.roles, isNull);
        expect(emptyDto.accessToken, isNull);
        expect(emptyDto.isAuthenticated, isNull);
      },
    );

    test('VerifyFirstTimeOtpResponseDto handles complete JSON and nulls', () {
      final json = {
        'verified': true,
        'verificationToken': 'token-123',
        'phone': '+966501234567',
        'role': 'Driver',
        'message': 'Success',
      };
      final dto = VerifyFirstTimeOtpResponseDto.fromJson(json);
      expect(dto.verified, isTrue);
      expect(dto.verificationToken, 'token-123');

      final emptyDto = VerifyFirstTimeOtpResponseDto.fromJson({});
      expect(emptyDto.verified, isNull);
      expect(emptyDto.verificationToken, isNull);
    });

    test('StaffMessageResponseDto handles complete JSON and nulls', () {
      final json = {'success': true, 'message': 'OTP sent'};
      final dto = StaffMessageResponseDto.fromJson(json);
      expect(dto.success, isTrue);
      expect(dto.message, 'OTP sent');

      final emptyDto = StaffMessageResponseDto.fromJson({});
      expect(emptyDto.success, isNull);
      expect(emptyDto.message, isNull);
    });
  });
}

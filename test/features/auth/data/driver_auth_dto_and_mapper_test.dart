import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/auth/data/mapper/auth_response_mapper.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_first_time_setup_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_forgot_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_login_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_phone_lookup_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_resend_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_reset_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_verify_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/driver_auth_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/driver_message_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/driver_phone_lookup_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

void main() {
  group('Driver Auth Request DTOs serialization tests', () {
    test('DriverPhoneLookupRequestDto serializes exact phone field without role', () {
      const dto = DriverPhoneLookupRequestDto(phone: '+966500000001');
      final json = dto.toJson();
      expect(json, equals({'phone': '+966500000001'}));
      expect(json.containsKey('role'), isFalse);
    });

    test('DriverFirstTimeSetupRequestDto serializes phone, otpCode, password only', () {
      const dto = DriverFirstTimeSetupRequestDto(
        phone: '+966500000001',
        otpCode: '123456',
        password: 'ValidPassword123!',
      );
      final json = dto.toJson();
      expect(
        json,
        equals({
          'phone': '+966500000001',
          'otpCode': '123456',
          'password': 'ValidPassword123!',
        }),
      );
      expect(json.containsKey('otp'), isFalse);
      expect(json.containsKey('newPassword'), isFalse);
      expect(json.containsKey('confirmPassword'), isFalse);
      expect(json.containsKey('role'), isFalse);
    });

    test('DriverLoginRequestDto serializes phone and password, omitting null email and role', () {
      const dto = DriverLoginRequestDto(
        phone: '+966500000001',
        password: 'ValidPassword123!',
      );
      final json = dto.toJson();
      expect(
        json,
        equals({
          'phone': '+966500000001',
          'password': 'ValidPassword123!',
        }),
      );
      expect(json.containsKey('role'), isFalse);
      expect(json.containsKey('email'), isFalse);
    });

    test('DriverResendOtpRequestDto serializes exact destination, channel, purpose', () {
      const dto = DriverResendOtpRequestDto(
        destination: '+966500000001',
        channel: 'Phone',
        purpose: 'VerifyPhone',
      );
      final json = dto.toJson();
      expect(
        json,
        equals({
          'destination': '+966500000001',
          'channel': 'Phone',
          'purpose': 'VerifyPhone',
        }),
      );
      expect(json.containsKey('role'), isFalse);
      expect(json.containsKey('phone'), isFalse);
    });

    test('DriverVerifyOtpRequestDto serializes destination, purpose, code', () {
      const dto = DriverVerifyOtpRequestDto(
        destination: '+966500000001',
        purpose: 'VerifyPhone',
        code: '123456',
      );
      final json = dto.toJson();
      expect(
        json,
        equals({
          'destination': '+966500000001',
          'purpose': 'VerifyPhone',
          'code': '123456',
        }),
      );
    });

    test('DriverForgotPasswordRequestDto serializes phone only', () {
      const dto = DriverForgotPasswordRequestDto(phone: '+966500000001');
      final json = dto.toJson();
      expect(json, equals({'phone': '+966500000001'}));
      expect(json.containsKey('role'), isFalse);
    });

    test('DriverResetPasswordRequestDto serializes phone, otpCode, newPassword only', () {
      const dto = DriverResetPasswordRequestDto(
        phone: '+966500000001',
        otpCode: '123456',
        newPassword: 'NewPassword123!',
      );
      final json = dto.toJson();
      expect(
        json,
        equals({
          'phone': '+966500000001',
          'otpCode': '123456',
          'newPassword': 'NewPassword123!',
        }),
      );
      expect(json.containsKey('role'), isFalse);
      expect(json.containsKey('confirmPassword'), isFalse);
    });
  });

  group('Driver Auth Response DTOs & Mappers', () {
    test('DriverPhoneLookupResponseDto parses and maps both requiresFirstTimeSetup and accountStatus', () {
      final json = {
        'exists': true,
        'requiresFirstTimeSetup': true,
        'fullName': 'Ahmed Al-Ghamdi',
        'restaurantName': 'Burger Corner',
        'accountStatus': 'PendingApproval',
      };
      final dto = DriverPhoneLookupResponseDto.fromJson(json);
      expect(dto.exists, isTrue);
      expect(dto.requiresFirstTimeSetup, isTrue);
      expect(dto.fullName, 'Ahmed Al-Ghamdi');
      expect(dto.restaurantName, 'Burger Corner');
      expect(dto.accountStatus, 'PendingApproval');

      final entity = dto.toEntity(fallbackPhone: '+966500000001');
      expect(entity.exists, isTrue);
      expect(entity.isFirstTimeSetup, isTrue);
      expect(entity.fullName, 'Ahmed Al-Ghamdi');
      expect(entity.restaurantName, 'Burger Corner');
      expect(entity.role, UserRole.driver);
      expect(entity.phone, '+966500000001');
      expect(entity.status, 'PendingApproval');
    });

    test('DriverPhoneLookupResponseDto tolerates null fields defensively', () {
      final dto = DriverPhoneLookupResponseDto.fromJson({});
      expect(dto.exists, isNull);
      expect(dto.requiresFirstTimeSetup, isNull);
      expect(dto.fullName, isNull);
      expect(dto.restaurantName, isNull);
      expect(dto.accountStatus, isNull);

      final entity = dto.toEntity();
      expect(entity.exists, isFalse);
      expect(entity.isFirstTimeSetup, isFalse);
    });

    test('DriverAuthResponseDto deserializes top-level session response and maps to AuthSessionEntity', () {
      final json = {
        'accessToken': 'jwt_access_token_123',
        'refreshToken': 'refresh_token_456',
        'tokenType': 'Bearer',
        'expiresIn': 86400,
        'userId': 'd1e2f3a4-b5c6-7d8e-9f0a-1b2c3d4e5f6a',
        'phoneNumber': '+966500000001',
        'fullName': 'Ahmed Al-Ghamdi',
        'userType': 'Driver',
        'accountStatus': 'PendingApproval',
        'restaurantId': null,
        'roles': ['Driver'],
        'permissions': <String>[],
        'nextStep': 'Review',
      };
      final dto = DriverAuthResponseDto.fromJson(json);
      expect(dto.accessToken, 'jwt_access_token_123');
      expect(dto.refreshToken, 'refresh_token_456');
      expect(dto.userId, 'd1e2f3a4-b5c6-7d8e-9f0a-1b2c3d4e5f6a');
      expect(dto.phoneNumber, '+966500000001');
      expect(dto.fullName, 'Ahmed Al-Ghamdi');
      expect(dto.userType, 'Driver');
      expect(dto.accountStatus, 'PendingApproval');
      expect(dto.roles, equals(['Driver']));

      final session = dto.toSessionEntity();
      expect(session.isAuthenticated, isTrue);
      expect(session.accessToken, 'jwt_access_token_123');
      expect(session.refreshToken, 'refresh_token_456');
      expect(session.user.userId, 'd1e2f3a4-b5c6-7d8e-9f0a-1b2c3d4e5f6a');
      expect(session.user.phoneNumber, '+966500000001');
      expect(session.user.fullName, 'Ahmed Al-Ghamdi');
      expect(session.user.role, UserRole.driver);
      expect(session.user.accountStatus, 'PendingApproval');
      expect(session.accessTokenExpiresAtUtc, isNotNull);
    });

    test('DriverMessageResponseDto deserializes message response', () {
      final json = {'message': 'OTP sent successfully', 'success': true};
      final dto = DriverMessageResponseDto.fromJson(json);
      expect(dto.message, 'OTP sent successfully');
      expect(dto.success, isTrue);
    });
  });
}

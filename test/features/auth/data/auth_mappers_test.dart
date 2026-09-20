import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/auth/data/mapper/auth_request_mapper.dart';
import 'package:meal_mate_delivery/features/auth/data/mapper/auth_response_mapper.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/phone_lookup_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_application_status_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_auth_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/verify_first_time_otp_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/forgot_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/resend_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/set_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_login_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

void main() {
  group('Auth Request Mappers', () {
    test('maps PhoneLookupRequestEntity to DTO with exact API role', () {
      const driverReq = PhoneLookupRequestEntity(
        phone: '+966501234567',
        role: UserRole.driver,
      );
      final driverDto = driverReq.toDto();
      expect(driverDto.phone, '+966501234567');
      expect(driverDto.role, 'Driver');

      const opsReq = PhoneLookupRequestEntity(
        phone: '+966501234567',
        role: UserRole.operations,
      );
      final opsDto = opsReq.toDto();
      expect(opsDto.role, 'DeliveryManager');
    });

    test('maps VerifyFirstTimeOtpRequestEntity to DTO', () {
      const entity = VerifyFirstTimeOtpRequestEntity(
        phone: '+966501234567',
        role: UserRole.driver,
        otpCode: '654321',
      );
      final dto = entity.toDto();
      expect(dto.phone, '+966501234567');
      expect(dto.role, 'Driver');
      expect(dto.otpCode, '654321');
    });

    test('maps SetPasswordRequestEntity to DTO', () {
      const entity = SetPasswordRequestEntity(
        phone: '+966501234567',
        role: UserRole.driver,
        verificationToken: 'v-tok',
        newPassword: 'pwd',
        confirmPassword: 'pwd',
      );
      final dto = entity.toDto();
      expect(dto.verificationToken, 'v-tok');
      expect(dto.newPassword, 'pwd');
    });

    test('maps StaffLoginRequestEntity to DTO', () {
      const entity = StaffLoginRequestEntity(
        phone: '+966501234567',
        role: UserRole.operations,
        password: 'pwd',
      );
      final dto = entity.toDto();
      expect(dto.role, 'DeliveryManager');
      expect(dto.password, 'pwd');
    });

    test('maps ForgotPassword, ResetPassword, ResendOtp to DTOs', () {
      const forgot = ForgotPasswordRequestEntity(
        phone: '+966501234567',
        role: UserRole.driver,
      );
      expect(forgot.toDto().role, 'Driver');

      const reset = ResetPasswordRequestEntity(
        phone: '+966501234567',
        role: UserRole.driver,
        otpCode: '111111',
        newPassword: 'np',
        confirmPassword: 'np',
      );
      expect(reset.toDto().otpCode, '111111');

      const resend = ResendOtpRequestEntity(
        phone: '+966501234567',
        role: UserRole.operations,
      );
      expect(resend.toDto().role, 'DeliveryManager');
    });
  });

  group('Auth Response Mappers', () {
    test('maps PhoneLookupResponseDto to PhoneLookupResultEntity with defaults on null', () {
      const dto = PhoneLookupResponseDto(
        exists: true,
        isFirstTimeSetup: true,
        role: 'Driver',
        phone: '+966501234567',
        applicationStatus: StaffApplicationStatusDto(
          stage: 1,
          badge: 'قيد المراجعة',
        ),
      );

      final entity = dto.toEntity(fallbackRole: UserRole.driver);
      expect(entity.exists, isTrue);
      expect(entity.isFirstTimeSetup, isTrue);
      expect(entity.role, UserRole.driver);
      expect(entity.applicationStatus?.stage, 1);

      // Null handling
      const emptyDto = PhoneLookupResponseDto();
      final defaultEntity = emptyDto.toEntity(
        fallbackRole: UserRole.operations,
        fallbackPhone: '+966500000000',
      );
      expect(defaultEntity.exists, isFalse);
      expect(defaultEntity.isFirstTimeSetup, isFalse);
      expect(defaultEntity.role, UserRole.operations);
      expect(defaultEntity.phone, '+966500000000');
      expect(defaultEntity.applicationStatus, isNull);
    });

    test('maps VerifyFirstTimeOtpResponseDto to entity', () {
      const dto = VerifyFirstTimeOtpResponseDto(
        verified: true,
        verificationToken: 'v-tok',
        role: 'DeliveryManager',
      );
      final entity = dto.toEntity();
      expect(entity.verified, isTrue);
      expect(entity.verificationToken, 'v-tok');
      expect(entity.role, UserRole.operations);
    });

    test('maps StaffAuthResponseDto to AuthSessionEntity', () {
      const dto = StaffAuthResponseDto(
        userId: 'u-123',
        phoneNumber: '+966501234567',
        fullName: 'John Doe',
        userType: 'Driver',
        accessToken: 'access-jwt',
        refreshToken: 'refresh-jwt',
        accessTokenExpiresAtUtc: '2026-09-20T12:00:00.000Z',
        isAuthenticated: true,
      );
      final session = dto.toSessionEntity();
      expect(session.user.userId, 'u-123');
      expect(session.user.role, UserRole.driver);
      expect(session.accessToken, 'access-jwt');
      expect(session.refreshToken, 'refresh-jwt');
      expect(session.accessTokenExpiresAtUtc?.year, 2026);
      expect(session.isAuthenticated, isTrue);
    });
  });
}

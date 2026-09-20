import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/auth_session_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/auth_user_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/forgot_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/resend_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/set_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_login_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/repo/auth_repository.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/forgot_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/login_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/logout_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/lookup_phone_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/resend_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/restore_session_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/set_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/verify_first_time_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

class MockAuthRepository implements AuthRepository {
  dynamic lastCallArg;
  String? lastMethod;

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async {
    lastMethod = 'lookupPhone';
    lastCallArg = request;
    return ApiSuccessResult(
      data: PhoneLookupResultEntity(
        exists: true,
        isFirstTimeSetup: false,
        role: request.role,
        phone: request.phone,
      ),
    );
  }

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async {
    lastMethod = 'verifyFirstTimeOtp';
    lastCallArg = request;
    return ApiSuccessResult(
      data: VerifyFirstTimeOtpResultEntity(
        verified: true,
        verificationToken: 'token',
        phone: request.phone,
        role: request.role,
      ),
    );
  }

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async {
    lastMethod = 'setPassword';
    lastCallArg = request;
    return ApiSuccessResult(
      data: AuthSessionEntity(
        user: AuthUserEntity(
          userId: 'u1',
          phoneNumber: request.phone,
          fullName: 'Test User',
          role: request.role,
        ),
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    );
  }

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async {
    lastMethod = 'login';
    lastCallArg = request;
    return ApiSuccessResult(
      data: AuthSessionEntity(
        user: AuthUserEntity(
          userId: 'u1',
          phoneNumber: request.phone,
          fullName: 'Test User',
          role: request.role,
        ),
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    );
  }

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async {
    lastMethod = 'forgotPassword';
    lastCallArg = request;
    return ApiSuccessResult(data: 'sent');
  }

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async {
    lastMethod = 'resetPassword';
    lastCallArg = request;
    return ApiSuccessResult(data: 'reset');
  }

  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) async {
    lastMethod = 'resendOtp';
    lastCallArg = request;
    return ApiSuccessResult(data: 'resent');
  }

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async {
    lastMethod = 'restoreSession';
    return ApiSuccessResult(data: null);
  }

  @override
  Future<ApiResult<void>> logout() async {
    lastMethod = 'logout';
    return ApiSuccessResult(data: null);
  }
}

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  test('LookupPhoneUseCase delegates to repository', () async {
    final useCase = LookupPhoneUseCase(repo);
    final request = const PhoneLookupRequestEntity(
      phone: '+966501234567',
      role: UserRole.driver,
    );
    final result = await useCase(request);

    expect(repo.lastMethod, 'lookupPhone');
    expect(identical(repo.lastCallArg, request), isTrue);
    expect(result, isA<ApiSuccessResult<PhoneLookupResultEntity>>());
  });

  test('VerifyFirstTimeOtpUseCase delegates to repository', () async {
    final useCase = VerifyFirstTimeOtpUseCase(repo);
    final request = const VerifyFirstTimeOtpRequestEntity(
      phone: '+966501234567',
      role: UserRole.driver,
      otpCode: '123456',
    );
    final result = await useCase(request);

    expect(repo.lastMethod, 'verifyFirstTimeOtp');
    expect(identical(repo.lastCallArg, request), isTrue);
    expect(result, isA<ApiSuccessResult<VerifyFirstTimeOtpResultEntity>>());
  });

  test('SetPasswordUseCase delegates to repository', () async {
    final useCase = SetPasswordUseCase(repo);
    final request = const SetPasswordRequestEntity(
      phone: '+966501234567',
      role: UserRole.driver,
      verificationToken: 'token',
      newPassword: 'pwd',
      confirmPassword: 'pwd',
    );
    final result = await useCase(request);

    expect(repo.lastMethod, 'setPassword');
    expect(identical(repo.lastCallArg, request), isTrue);
    expect(result, isA<ApiSuccessResult<AuthSessionEntity>>());
  });

  test('LoginUseCase delegates to repository', () async {
    final useCase = LoginUseCase(repo);
    final request = const StaffLoginRequestEntity(
      phone: '+966501234567',
      role: UserRole.operations,
      password: 'pwd',
    );
    final result = await useCase(request);

    expect(repo.lastMethod, 'login');
    expect(identical(repo.lastCallArg, request), isTrue);
    expect(result, isA<ApiSuccessResult<AuthSessionEntity>>());
  });

  test('ForgotPasswordUseCase delegates to repository', () async {
    final useCase = ForgotPasswordUseCase(repo);
    final request = const ForgotPasswordRequestEntity(
      phone: '+966501234567',
      role: UserRole.operations,
    );
    final result = await useCase(request);

    expect(repo.lastMethod, 'forgotPassword');
    expect(identical(repo.lastCallArg, request), isTrue);
    expect(result, isA<ApiSuccessResult<String>>());
  });

  test('ResetPasswordUseCase delegates to repository', () async {
    final useCase = ResetPasswordUseCase(repo);
    final request = const ResetPasswordRequestEntity(
      phone: '+966501234567',
      role: UserRole.driver,
      otpCode: '123456',
      newPassword: 'pwd',
      confirmPassword: 'pwd',
    );
    final result = await useCase(request);

    expect(repo.lastMethod, 'resetPassword');
    expect(identical(repo.lastCallArg, request), isTrue);
    expect(result, isA<ApiSuccessResult<String>>());
  });

  test('ResendOtpUseCase delegates to repository', () async {
    final useCase = ResendOtpUseCase(repo);
    final request = const ResendOtpRequestEntity(
      phone: '+966501234567',
      role: UserRole.driver,
    );
    final result = await useCase(request);

    expect(repo.lastMethod, 'resendOtp');
    expect(identical(repo.lastCallArg, request), isTrue);
    expect(result, isA<ApiSuccessResult<String>>());
  });

  test('RestoreSessionUseCase delegates to repository', () async {
    final useCase = RestoreSessionUseCase(repo);
    final result = await useCase();

    expect(repo.lastMethod, 'restoreSession');
    expect(result, isA<ApiSuccessResult<AuthSessionEntity?>>());
  });

  test('LogoutUseCase delegates to repository', () async {
    final useCase = LogoutUseCase(repo);
    final result = await useCase();

    expect(repo.lastMethod, 'logout');
    expect(result, isA<ApiSuccessResult<void>>());
  });
}

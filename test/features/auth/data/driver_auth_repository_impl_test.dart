import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_first_time_setup_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_forgot_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_login_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_phone_lookup_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_resend_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_reset_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/driver_verify_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/forgot_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/phone_lookup_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/refresh_token_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/resend_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/reset_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/set_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/staff_login_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/verify_first_time_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/driver_auth_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/driver_message_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/driver_phone_lookup_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/phone_lookup_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_auth_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_message_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_role_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/verify_first_time_otp_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/repo/auth_repository_impl.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/forgot_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/resend_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/set_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_login_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDriverAuthRemoteDataSource implements AuthRemoteDataSource {
  dynamic errorToThrow;

  DriverPhoneLookupRequestDto? lastDriverLookupRequest;
  DriverFirstTimeSetupRequestDto? lastFirstTimeSetupRequest;
  DriverLoginRequestDto? lastDriverLoginRequest;
  DriverResendOtpRequestDto? lastDriverResendOtpRequest;
  DriverVerifyOtpRequestDto? lastDriverVerifyOtpRequest;
  DriverForgotPasswordRequestDto? lastDriverForgotPasswordRequest;
  DriverResetPasswordRequestDto? lastDriverResetPasswordRequest;
  PhoneLookupRequestDto? lastStaffLookupRequest;

  DriverPhoneLookupResponseDto driverPhoneLookupResponse =
      const DriverPhoneLookupResponseDto(
        exists: true,
        requiresFirstTimeSetup: true,
        fullName: 'Driver Name',
        restaurantName: 'Test Rest',
        accountStatus: 'PendingApproval',
      );

  DriverAuthResponseDto driverAuthResponse = const DriverAuthResponseDto(
    accessToken: 'access_driver_123',
    refreshToken: 'refresh_driver_456',
    userId: 'driver_uid_789',
    phoneNumber: '+966500000001',
    fullName: 'Driver Name',
    userType: 'Driver',
    roles: ['Driver'],
    accountStatus: 'PendingApproval',
  );

  DriverMessageResponseDto driverMessageResponse =
      const DriverMessageResponseDto(
        message: 'Success Message',
        success: true,
      );

  PhoneLookupResponseDto staffLookupResponse = const PhoneLookupResponseDto(
    exists: true,
    isFirstTimeSetup: false,
    fullName: 'Staff User',
  );

  @override
  Future<DriverPhoneLookupResponseDto> driverLookupPhone(
    DriverPhoneLookupRequestDto request,
  ) async {
    lastDriverLookupRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return driverPhoneLookupResponse;
  }

  @override
  Future<DriverAuthResponseDto> driverFirstTimeSetup(
    DriverFirstTimeSetupRequestDto request,
  ) async {
    lastFirstTimeSetupRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return driverAuthResponse;
  }

  @override
  Future<DriverAuthResponseDto> driverLogin(
    DriverLoginRequestDto request,
  ) async {
    lastDriverLoginRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return driverAuthResponse;
  }

  @override
  Future<DriverMessageResponseDto> driverResendOtp(
    DriverResendOtpRequestDto request,
  ) async {
    lastDriverResendOtpRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return driverMessageResponse;
  }

  @override
  Future<DriverMessageResponseDto> driverVerifyOtp(
    DriverVerifyOtpRequestDto request,
  ) async {
    lastDriverVerifyOtpRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return driverMessageResponse;
  }

  @override
  Future<DriverMessageResponseDto> driverForgotPassword(
    DriverForgotPasswordRequestDto request,
  ) async {
    lastDriverForgotPasswordRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return driverMessageResponse;
  }

  @override
  Future<DriverMessageResponseDto> driverResetPassword(
    DriverResetPasswordRequestDto request,
  ) async {
    lastDriverResetPasswordRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return driverMessageResponse;
  }

  @override
  Future<PhoneLookupResponseDto> lookupPhone(
    PhoneLookupRequestDto request,
  ) async {
    lastStaffLookupRequest = request;
    if (errorToThrow != null) throw errorToThrow;
    return staffLookupResponse;
  }

  @override
  Future<VerifyFirstTimeOtpResponseDto> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestDto request,
  ) async => const VerifyFirstTimeOtpResponseDto(verified: true);

  @override
  Future<StaffAuthResponseDto> setPassword(
    SetPasswordRequestDto request,
  ) async => const StaffAuthResponseDto();

  @override
  Future<StaffAuthResponseDto> login(
    StaffLoginRequestDto request,
  ) async => const StaffAuthResponseDto();

  @override
  Future<StaffMessageResponseDto> forgotPassword(
    ForgotPasswordRequestDto request,
  ) async => const StaffMessageResponseDto();

  @override
  Future<StaffMessageResponseDto> resetPassword(
    ResetPasswordRequestDto request,
  ) async => const StaffMessageResponseDto();

  @override
  Future<StaffMessageResponseDto> resendOtp(
    ResendOtpRequestDto request,
  ) async => const StaffMessageResponseDto();

  @override
  Future<StaffAuthResponseDto> refreshToken(
    RefreshTokenRequestDto request,
  ) async => const StaffAuthResponseDto();

  @override
  Future<List<StaffRoleResponseDto>> getStaffRoles() async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDriverAuthRemoteDataSource remoteDataSource;
  late TokenService tokenService;
  late AuthRepositoryImpl repository;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tokenService = TokenService(
      secureStorage: const FlutterSecureStorage(),
      sharedPreferences: prefs,
    );
    remoteDataSource = FakeDriverAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource, tokenService);
  });

  group('Driver Auth Repository Operations', () {
    test('lookupPhone for UserRole.driver calls driverLookupPhone without role field', () async {
      final result = await repository.lookupPhone(
        const PhoneLookupRequestEntity(
          phone: '+966500000001',
          role: UserRole.driver,
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      final entity = (result as ApiSuccessResult).data;
      expect(entity.exists, isTrue);
      expect(entity.isFirstTimeSetup, isTrue);
      expect(entity.fullName, 'Driver Name');
      expect(entity.restaurantName, 'Test Rest');
      expect(entity.role, UserRole.driver);
      expect(entity.phone, '+966500000001');

      expect(remoteDataSource.lastDriverLookupRequest?.phone, '+966500000001');
      expect(remoteDataSource.lastStaffLookupRequest, isNull);
    });

    test('lookupPhone 404 returns typed ApiErrorResult, not exists: false', () async {
      remoteDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/drivers/lookup-phone'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/api/v1/auth/drivers/lookup-phone'),
          data: {'detail': 'Driver not found'},
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.lookupPhone(
        const PhoneLookupRequestEntity(
          phone: '+966500000999',
          role: UserRole.driver,
        ),
      );

      expect(result, isA<ApiErrorResult>());
    });

    test('setPassword for UserRole.driver calls driverFirstTimeSetup and persists session', () async {
      final result = await repository.setPassword(
        const SetPasswordRequestEntity(
          phone: '+966500000001',
          role: UserRole.driver,
          verificationToken: '123456',
          newPassword: 'Password123!',
          confirmPassword: 'Password123!',
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      expect(remoteDataSource.lastFirstTimeSetupRequest?.phone, '+966500000001');
      expect(remoteDataSource.lastFirstTimeSetupRequest?.otpCode, '123456');
      expect(remoteDataSource.lastFirstTimeSetupRequest?.password, 'Password123!');

      final token = await tokenService.getToken();
      expect(token, 'access_driver_123');
      final userId = tokenService.getCurrentUserId();
      expect(userId, 'driver_uid_789');
      final savedRole = tokenService.getSavedRole();
      expect(savedRole, 'Driver');
    });

    test('login for UserRole.driver calls driverLogin and persists session', () async {
      final result = await repository.login(
        const StaffLoginRequestEntity(
          phone: '+966500000001',
          role: UserRole.driver,
          password: 'Password123!',
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      expect(remoteDataSource.lastDriverLoginRequest?.phone, '+966500000001');
      expect(remoteDataSource.lastDriverLoginRequest?.password, 'Password123!');

      final token = await tokenService.getToken();
      expect(token, 'access_driver_123');
      final userId = tokenService.getCurrentUserId();
      expect(userId, 'driver_uid_789');
      final savedRole = tokenService.getSavedRole();
      expect(savedRole, 'Driver');
    });

    test('resendOtp for UserRole.driver calls driverResendOtp', () async {
      final result = await repository.resendOtp(
        const ResendOtpRequestEntity(
          phone: '+966500000001',
          role: UserRole.driver,
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      expect(remoteDataSource.lastDriverResendOtpRequest?.destination, '+966500000001');
      expect(remoteDataSource.lastDriverResendOtpRequest?.purpose, 'VerifyPhone');
    });

    test('forgotPassword for UserRole.driver calls driverForgotPassword', () async {
      final result = await repository.forgotPassword(
        const ForgotPasswordRequestEntity(
          phone: '+966500000001',
          role: UserRole.driver,
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      expect(remoteDataSource.lastDriverForgotPasswordRequest?.phone, '+966500000001');
    });

    test('resetPassword for UserRole.driver calls driverResetPassword', () async {
      final result = await repository.resetPassword(
        const ResetPasswordRequestEntity(
          phone: '+966500000001',
          role: UserRole.driver,
          otpCode: '654321',
          newPassword: 'NewPassword123!',
          confirmPassword: 'NewPassword123!',
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      expect(remoteDataSource.lastDriverResetPasswordRequest?.phone, '+966500000001');
      expect(remoteDataSource.lastDriverResetPasswordRequest?.otpCode, '654321');
      expect(remoteDataSource.lastDriverResetPasswordRequest?.newPassword, 'NewPassword123!');
    });

    test('lookupPhone for UserRole.operations calls staff lookupPhone as regression check', () async {
      final result = await repository.lookupPhone(
        const PhoneLookupRequestEntity(
          phone: '+96512345678',
          role: UserRole.operations,
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      expect(remoteDataSource.lastStaffLookupRequest?.phone, '+96512345678');
      expect(remoteDataSource.lastDriverLookupRequest, isNull);
    });
  });
}

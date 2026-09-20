import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/forgot_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/phone_lookup_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/refresh_token_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/resend_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/reset_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/set_password_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/staff_login_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/verify_first_time_otp_request_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/phone_lookup_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_auth_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/staff_message_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/models/response/verify_first_time_otp_response_dto.dart';
import 'package:meal_mate_delivery/features/auth/data/repo/auth_repository_impl.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/auth_session_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/forgot_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/resend_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/set_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_login_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  dynamic errorToThrow;

  PhoneLookupResponseDto phoneLookupResponse = const PhoneLookupResponseDto(
    exists: true,
    isFirstTimeSetup: false,
    role: 'Driver',
    phone: '+966501234567',
  );

  VerifyFirstTimeOtpResponseDto verifyOtpResponse =
      const VerifyFirstTimeOtpResponseDto(
    verified: true,
    verificationToken: 'v-tok',
    role: 'Driver',
  );

  StaffAuthResponseDto authResponse = const StaffAuthResponseDto(
    userId: 'user-1',
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
    userType: 'Driver',
    isAuthenticated: true,
  );

  StaffMessageResponseDto messageResponse = const StaffMessageResponseDto(
    success: true,
    message: 'Success Message',
  );

  @override
  Future<PhoneLookupResponseDto> lookupPhone(PhoneLookupRequestDto request) async {
    if (errorToThrow != null) throw errorToThrow;
    return phoneLookupResponse;
  }

  @override
  Future<VerifyFirstTimeOtpResponseDto> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow;
    return verifyOtpResponse;
  }

  @override
  Future<StaffAuthResponseDto> setPassword(SetPasswordRequestDto request) async {
    if (errorToThrow != null) throw errorToThrow;
    return authResponse;
  }

  @override
  Future<StaffAuthResponseDto> login(StaffLoginRequestDto request) async {
    if (errorToThrow != null) throw errorToThrow;
    return authResponse;
  }

  @override
  Future<StaffMessageResponseDto> forgotPassword(
    ForgotPasswordRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow;
    return messageResponse;
  }

  @override
  Future<StaffMessageResponseDto> resetPassword(
    ResetPasswordRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow;
    return messageResponse;
  }

  @override
  Future<StaffMessageResponseDto> resendOtp(ResendOtpRequestDto request) async {
    if (errorToThrow != null) throw errorToThrow;
    return messageResponse;
  }

  @override
  Future<StaffAuthResponseDto> refreshToken(RefreshTokenRequestDto request) async {
    if (errorToThrow != null) throw errorToThrow;
    return authResponse;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRemoteDataSource remoteDataSource;
  late TokenService tokenService;
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    tokenService = TokenService(
      secureStorage: secureStorage,
      sharedPreferences: prefs,
    );

    remoteDataSource = FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource, tokenService);
  });

  group('AuthRepositoryImpl tests', () {
    test('lookupPhone returns ApiSuccessResult on success', () async {
      final result = await repository.lookupPhone(
        const PhoneLookupRequestEntity(
          phone: '+966501234567',
          role: UserRole.driver,
        ),
      );

      expect(result, isA<ApiSuccessResult<PhoneLookupResultEntity>>());
      final data = (result as ApiSuccessResult<PhoneLookupResultEntity>).data;
      expect(data.exists, isTrue);
      expect(data.role, UserRole.driver);
    });

    test('lookupPhone returns ApiErrorResult on DioException', () async {
      remoteDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 404,
          data: {'detail': 'User not found'},
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.lookupPhone(
        const PhoneLookupRequestEntity(
          phone: '+966501234567',
          role: UserRole.driver,
        ),
      );

      expect(result, isA<ApiErrorResult<PhoneLookupResultEntity>>());
    });

    test('login saves tokens to TokenService and returns AuthSessionEntity', () async {
      final result = await repository.login(
        const StaffLoginRequestEntity(
          phone: '+966501234567',
          role: UserRole.driver,
          password: 'pwd',
        ),
      );

      expect(result, isA<ApiSuccessResult<AuthSessionEntity>>());
      final session = (result as ApiSuccessResult<AuthSessionEntity>).data;
      expect(session.accessToken, 'access-1');

      // Verify tokens are saved in TokenService
      expect(await tokenService.getToken(), 'access-1');
      expect(await tokenService.getRefreshToken(), 'refresh-1');
      expect(tokenService.getCurrentUserId(), 'user-1');
    });

    test('setPassword saves tokens to TokenService and returns AuthSessionEntity', () async {
      final result = await repository.setPassword(
        const SetPasswordRequestEntity(
          phone: '+966501234567',
          role: UserRole.driver,
          verificationToken: 'v-tok',
          newPassword: 'pwd',
          confirmPassword: 'pwd',
        ),
      );

      expect(result, isA<ApiSuccessResult<AuthSessionEntity>>());
      expect(await tokenService.getToken(), 'access-1');
    });

    test('logout clears tokens from TokenService', () async {
      await tokenService.saveAccessToken('some-access');
      await tokenService.saveRefreshToken('some-refresh');

      final result = await repository.logout();
      expect(result, isA<ApiSuccessResult<void>>());

      expect(await tokenService.getToken(), isNull);
      expect(await tokenService.getRefreshToken(), isNull);
    });
  });
}

import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/entities/forgot_password_request_entity.dart';
import '../../domain/entities/phone_lookup_request_entity.dart';
import '../../domain/entities/phone_lookup_result_entity.dart';
import '../../domain/entities/resend_otp_request_entity.dart';
import '../../domain/entities/reset_password_request_entity.dart';
import '../../domain/entities/set_password_request_entity.dart';
import '../../domain/entities/staff_login_request_entity.dart';
import '../../domain/entities/verify_first_time_otp_request_entity.dart';
import '../../domain/entities/verify_first_time_otp_result_entity.dart';
import '../../domain/repo/auth_repository.dart';
import '../../domain/user_role.dart';
import '../data_source/auth_remote_data_source.dart';
import '../mapper/auth_request_mapper.dart';
import '../mapper/auth_response_mapper.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenService,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final TokenService _tokenService;

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.lookupPhone(request.toDto());
      return response.toEntity(
        fallbackRole: request.role,
        fallbackPhone: request.phone,
      );
    });
  }

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.verifyFirstTimeOtp(
        request.toDto(),
      );
      return response.toEntity(
        fallbackRole: request.role,
        fallbackPhone: request.phone,
      );
    });
  }

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.setPassword(request.toDto());
      if (response.accessToken != null && response.accessToken!.isNotEmpty) {
        await _tokenService.saveAccessToken(response.accessToken!);
      }
      if (response.refreshToken != null && response.refreshToken!.isNotEmpty) {
        await _tokenService.saveRefreshToken(response.refreshToken!);
      }
      if (response.userId != null && response.userId!.isNotEmpty) {
        await _tokenService.saveCurrentUserId(response.userId!);
      }
      return response.toSessionEntity(
        fallbackRole: request.role,
        fallbackPhone: request.phone,
      );
    });
  }

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.login(request.toDto());
      if (response.accessToken != null && response.accessToken!.isNotEmpty) {
        await _tokenService.saveAccessToken(response.accessToken!);
      }
      if (response.refreshToken != null && response.refreshToken!.isNotEmpty) {
        await _tokenService.saveRefreshToken(response.refreshToken!);
      }
      if (response.userId != null && response.userId!.isNotEmpty) {
        await _tokenService.saveCurrentUserId(response.userId!);
      }
      return response.toSessionEntity(
        fallbackRole: request.role,
        fallbackPhone: request.phone,
      );
    });
  }

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.forgotPassword(request.toDto());
      return response.message ?? 'Success';
    });
  }

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.resetPassword(request.toDto());
      return response.message ?? 'Success';
    });
  }

  @override
  Future<ApiResult<String>> resendOtp(
    ResendOtpRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.resendOtp(request.toDto());
      return response.message ?? 'Success';
    });
  }

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() {
    return safeLocalCall(() async {
      final token = await _tokenService.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      final refreshToken = await _tokenService.getRefreshToken() ?? '';
      final userId = _tokenService.getCurrentUserId() ?? '';
      return AuthSessionEntity(
        user: AuthUserEntity(
          userId: userId,
          phoneNumber: '',
          fullName: '',
          role: UserRole.operations,
        ),
        accessToken: token,
        refreshToken: refreshToken,
        isAuthenticated: true,
      );
    });
  }

  @override
  Future<ApiResult<void>> logout() {
    return safeLocalCall(() async {
      await _tokenService.clearTokens();
    });
  }
}

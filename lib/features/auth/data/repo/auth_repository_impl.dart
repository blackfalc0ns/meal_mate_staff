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
import '../../domain/entities/staff_role_entity.dart';
import '../../domain/entities/verify_first_time_otp_request_entity.dart';
import '../../domain/entities/verify_first_time_otp_result_entity.dart';
import '../../domain/repo/auth_repository.dart';
import '../../domain/user_role.dart';
import '../data_source/auth_remote_data_source.dart';
import '../mapper/auth_request_mapper.dart';
import '../mapper/auth_response_mapper.dart';
import '../mapper/staff_role_mapper.dart';
import '../models/request/driver_first_time_setup_request_dto.dart';
import '../models/request/driver_forgot_password_request_dto.dart';
import '../models/request/driver_login_request_dto.dart';
import '../models/request/driver_phone_lookup_request_dto.dart';
import '../models/request/driver_resend_otp_request_dto.dart';
import '../models/request/driver_reset_password_request_dto.dart';
import '../models/request/driver_verify_otp_request_dto.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._tokenService);

  final AuthRemoteDataSource _remoteDataSource;
  final TokenService _tokenService;

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) {
    return safeApiCall(() async {
      if (request.role == UserRole.driver) {
        final response = await _remoteDataSource.driverLookupPhone(
          DriverPhoneLookupRequestDto(phone: request.phone),
        );
        return response.toEntity(
          fallbackRole: request.role,
          fallbackPhone: request.phone,
        );
      }
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
      if (request.role == UserRole.driver) {
        final response = await _remoteDataSource.driverVerifyOtp(
          DriverVerifyOtpRequestDto(
            destination: request.phone,
            code: request.otpCode,
          ),
        );
        return VerifyFirstTimeOtpResultEntity(
          verified: true,
          verificationToken: request.otpCode,
          phone: request.phone,
          role: request.role,
          message: response.message,
        );
      }
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
      if (request.role == UserRole.driver) {
        final response = await _remoteDataSource.driverFirstTimeSetup(
          DriverFirstTimeSetupRequestDto(
            phone: request.phone,
            otpCode: request.verificationToken,
            password: request.newPassword,
          ),
        );
        if (response.accessToken != null && response.accessToken!.isNotEmpty) {
          final roleStr = (response.roles != null && response.roles!.isNotEmpty)
              ? response.roles!.first
              : (response.userType ?? 'Driver');
          await _tokenService.saveSession(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken ?? '',
            userId: response.userId ?? '',
            role: roleStr,
            phone: response.phoneNumber ?? request.phone,
            fullName: response.fullName,
            restaurantId: response.restaurantId,
            accountStatus: response.accountStatus,
          );
        }
        return response.toSessionEntity(
          fallbackRole: request.role,
          fallbackPhone: request.phone,
        );
      }
      final response = await _remoteDataSource.setPassword(request.toDto());
      if (response.accessToken != null && response.accessToken!.isNotEmpty) {
        final roleStr = (response.roles != null && response.roles!.isNotEmpty)
            ? response.roles!.first
            : (response.userType ??
                  (request.role == UserRole.driver
                      ? 'Driver'
                      : 'DeliveryManager'));
        await _tokenService.saveSession(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken ?? '',
          userId: response.userId ?? '',
          role: roleStr,
          phone: response.phoneNumber ?? request.phone,
          fullName: response.fullName,
          restaurantId: response.restaurantId,
        );
      }
      return response.toSessionEntity(
        fallbackRole: request.role,
        fallbackPhone: request.phone,
      );
    });
  }

  @override
  Future<ApiResult<AuthSessionEntity>> login(StaffLoginRequestEntity request) {
    return safeApiCall(() async {
      if (request.role == UserRole.driver) {
        final response = await _remoteDataSource.driverLogin(
          DriverLoginRequestDto(
            phone: request.phone,
            password: request.password,
          ),
        );
        if (response.accessToken != null && response.accessToken!.isNotEmpty) {
          final roleStr = (response.roles != null && response.roles!.isNotEmpty)
              ? response.roles!.first
              : (response.userType ?? 'Driver');
          await _tokenService.saveSession(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken ?? '',
            userId: response.userId ?? '',
            role: roleStr,
            phone: response.phoneNumber ?? request.phone,
            fullName: response.fullName,
            restaurantId: response.restaurantId,
            accountStatus: response.accountStatus,
          );
        }
        return response.toSessionEntity(
          fallbackRole: request.role,
          fallbackPhone: request.phone,
        );
      }
      final response = await _remoteDataSource.login(request.toDto());
      if (response.accessToken != null && response.accessToken!.isNotEmpty) {
        final roleStr = (response.roles != null && response.roles!.isNotEmpty)
            ? response.roles!.first
            : (response.userType ??
                  (request.role == UserRole.driver
                      ? 'Driver'
                      : 'DeliveryManager'));
        await _tokenService.saveSession(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken ?? '',
          userId: response.userId ?? '',
          role: roleStr,
          phone: response.phoneNumber ?? request.phone,
          fullName: response.fullName,
          restaurantId: response.restaurantId,
        );
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
      if (request.role == UserRole.driver) {
        final response = await _remoteDataSource.driverForgotPassword(
          DriverForgotPasswordRequestDto(phone: request.phone),
        );
        return response.message ?? 'Success';
      }
      final response = await _remoteDataSource.forgotPassword(request.toDto());
      return response.message ?? 'Success';
    });
  }

  @override
  Future<ApiResult<String>> resetPassword(ResetPasswordRequestEntity request) {
    return safeApiCall(() async {
      if (request.role == UserRole.driver) {
        final response = await _remoteDataSource.driverResetPassword(
          DriverResetPasswordRequestDto(
            phone: request.phone,
            otpCode: request.otpCode,
            newPassword: request.newPassword,
          ),
        );
        return response.message ?? 'Success';
      }
      final response = await _remoteDataSource.resetPassword(request.toDto());
      return response.message ?? 'Success';
    });
  }

  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) {
    return safeApiCall(() async {
      if (request.role == UserRole.driver) {
        final response = await _remoteDataSource.driverResendOtp(
          DriverResendOtpRequestDto(destination: request.phone),
        );
        return response.message ?? 'Success';
      }
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
      final savedRole = _tokenService.getSavedRole();
      final savedPhone = _tokenService.getSavedPhone() ?? '';
      final savedName = _tokenService.getSavedFullName() ?? '';
      final role =
          (savedRole != null && savedRole.toLowerCase().contains('delivery'))
          ? UserRole.operations
          : UserRole.driver;

      return AuthSessionEntity(
        user: AuthUserEntity(
          userId: userId,
          phoneNumber: savedPhone,
          fullName: savedName,
          role: role,
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

  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getStaffRoles();
      return response.map((dto) => dto.toEntity()).toList();
    });
  }
}

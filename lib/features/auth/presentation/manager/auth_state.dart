import '../../../../core/network/failures.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/phone_lookup_result_entity.dart';
import '../../domain/entities/staff_role_entity.dart';
import '../../domain/entities/verify_first_time_otp_result_entity.dart';
import '../../domain/user_role.dart';

enum AuthStatus {
  initial,
  loading,
  lookupSuccess,
  otpVerified,
  passwordSetSuccess,
  loginSuccess,
  forgotPasswordSuccess,
  resetPasswordSuccess,
  otpResentSuccess,
  sessionRestored,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final bool isSuccess;
  final UserRole role;
  final String phone;
  final PhoneLookupResultEntity? lookupResult;
  final VerifyFirstTimeOtpResultEntity? otpResult;
  final AuthSessionEntity? session;
  final String? message;
  final Failure? failure;
  final String? errorMessage;
  final int resendCountdown;
  final bool canResendOtp;
  final List<StaffRoleEntity> roles;
  final bool isLoadingRoles;
  final Failure? rolesFailure;

  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.isSuccess = false,
    this.role = UserRole.operations,
    this.phone = '',
    this.lookupResult,
    this.otpResult,
    this.session,
    this.message,
    this.failure,
    this.errorMessage,
    this.resendCountdown = 60,
    this.canResendOtp = false,
    this.roles = const [],
    this.isLoadingRoles = false,
    this.rolesFailure,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    bool? isSuccess,
    UserRole? role,
    String? phone,
    PhoneLookupResultEntity? lookupResult,
    VerifyFirstTimeOtpResultEntity? otpResult,
    AuthSessionEntity? session,
    String? message,
    Failure? failure,
    String? errorMessage,
    int? resendCountdown,
    bool? canResendOtp,
    List<StaffRoleEntity>? roles,
    bool? isLoadingRoles,
    Failure? rolesFailure,
    bool clearLookupResult = false,
    bool clearOtpResult = false,
    bool clearSession = false,
    bool clearFeedback = false,
    bool clearRolesFailure = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      lookupResult: clearLookupResult
          ? null
          : (lookupResult ?? this.lookupResult),
      otpResult: clearOtpResult ? null : (otpResult ?? this.otpResult),
      session: clearSession ? null : (session ?? this.session),
      message: clearFeedback ? null : (message ?? this.message),
      failure: clearFeedback ? null : (failure ?? this.failure),
      errorMessage: clearFeedback ? null : (errorMessage ?? this.errorMessage),
      resendCountdown: resendCountdown ?? this.resendCountdown,
      canResendOtp: canResendOtp ?? this.canResendOtp,
      roles: roles ?? this.roles,
      isLoadingRoles: isLoadingRoles ?? this.isLoadingRoles,
      rolesFailure: clearRolesFailure ? null : (rolesFailure ?? this.rolesFailure),
    );
  }
}

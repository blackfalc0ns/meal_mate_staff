import '../../../../core/network/api_results.dart';
import '../entities/auth_session_entity.dart';
import '../entities/forgot_password_request_entity.dart';
import '../entities/phone_lookup_request_entity.dart';
import '../entities/phone_lookup_result_entity.dart';
import '../entities/resend_otp_request_entity.dart';
import '../entities/reset_password_request_entity.dart';
import '../entities/set_password_request_entity.dart';
import '../entities/staff_login_request_entity.dart';
import '../entities/verify_first_time_otp_request_entity.dart';
import '../entities/verify_first_time_otp_result_entity.dart';

abstract interface class AuthRepository {
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  );

  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  );

  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  );

  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  );

  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  );

  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  );

  Future<ApiResult<String>> resendOtp(
    ResendOtpRequestEntity request,
  );

  Future<ApiResult<AuthSessionEntity?>> restoreSession();

  Future<ApiResult<void>> logout();
}

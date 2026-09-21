import '../models/request/forgot_password_request_dto.dart';
import '../models/request/phone_lookup_request_dto.dart';
import '../models/request/refresh_token_request_dto.dart';
import '../models/request/resend_otp_request_dto.dart';
import '../models/request/reset_password_request_dto.dart';
import '../models/request/set_password_request_dto.dart';
import '../models/request/staff_login_request_dto.dart';
import '../models/request/verify_first_time_otp_request_dto.dart';
import '../models/response/phone_lookup_response_dto.dart';
import '../models/response/staff_auth_response_dto.dart';
import '../models/response/staff_message_response_dto.dart';
import '../models/response/staff_role_response_dto.dart';
import '../models/response/verify_first_time_otp_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<PhoneLookupResponseDto> lookupPhone(PhoneLookupRequestDto request);

  Future<VerifyFirstTimeOtpResponseDto> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestDto request,
  );

  Future<StaffAuthResponseDto> setPassword(SetPasswordRequestDto request);

  Future<StaffAuthResponseDto> login(StaffLoginRequestDto request);

  Future<StaffMessageResponseDto> forgotPassword(
    ForgotPasswordRequestDto request,
  );

  Future<StaffMessageResponseDto> resetPassword(
    ResetPasswordRequestDto request,
  );

  Future<StaffMessageResponseDto> resendOtp(ResendOtpRequestDto request);

  Future<StaffAuthResponseDto> refreshToken(RefreshTokenRequestDto request);

  Future<List<StaffRoleResponseDto>> getStaffRoles() async => const [];
}

import 'package:injectable/injectable.dart';

import '../../../../core/network/api_services.dart';
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
import '../models/response/verify_first_time_otp_response_dto.dart';
import 'auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<PhoneLookupResponseDto> lookupPhone(PhoneLookupRequestDto request) {
    return _apiServices.lookupPhone(request);
  }

  @override
  Future<VerifyFirstTimeOtpResponseDto> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestDto request,
  ) {
    return _apiServices.verifyFirstTimeOtp(request);
  }

  @override
  Future<StaffAuthResponseDto> setPassword(SetPasswordRequestDto request) {
    return _apiServices.setPassword(request);
  }

  @override
  Future<StaffAuthResponseDto> login(StaffLoginRequestDto request) {
    return _apiServices.login(request);
  }

  @override
  Future<StaffMessageResponseDto> forgotPassword(
    ForgotPasswordRequestDto request,
  ) {
    return _apiServices.forgotPassword(request);
  }

  @override
  Future<StaffMessageResponseDto> resetPassword(
    ResetPasswordRequestDto request,
  ) {
    return _apiServices.resetPassword(request);
  }

  @override
  Future<StaffMessageResponseDto> resendOtp(ResendOtpRequestDto request) {
    return _apiServices.resendOtp(request);
  }

  @override
  Future<StaffAuthResponseDto> refreshToken(RefreshTokenRequestDto request) {
    return _apiServices.refreshToken(request);
  }
}

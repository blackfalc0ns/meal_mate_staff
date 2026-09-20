import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/account_status/data/models/response/driver_registration_status_response_dto.dart';
import '../../features/auth/data/models/request/forgot_password_request_dto.dart';
import '../../features/auth/data/models/request/phone_lookup_request_dto.dart';
import '../../features/auth/data/models/request/refresh_token_request_dto.dart';
import '../../features/auth/data/models/request/resend_otp_request_dto.dart';
import '../../features/auth/data/models/request/reset_password_request_dto.dart';
import '../../features/auth/data/models/request/set_password_request_dto.dart';
import '../../features/auth/data/models/request/staff_login_request_dto.dart';
import '../../features/auth/data/models/request/verify_first_time_otp_request_dto.dart';
import '../../features/auth/data/models/response/phone_lookup_response_dto.dart';
import '../../features/auth/data/models/response/staff_auth_response_dto.dart';
import '../../features/auth/data/models/response/staff_message_response_dto.dart';
import '../../features/auth/data/models/response/verify_first_time_otp_response_dto.dart';
import '../../features/register/data/models/request/driver_registration_request_dto.dart';
import '../../features/register/data/models/request/driver_resubmit_request_dto.dart';
import '../../features/register/data/models/response/driver_file_upload_response_dto.dart';
import '../../features/register/data/models/response/driver_registration_response_dto.dart';
import '../../features/register/data/models/response/driver_restaurant_response_dto.dart';
import 'network_constants.dart';

part 'api_services.g.dart';

@RestApi()
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  // Shared staff auth endpoints
  @POST(EndPoints.lookupPhone)
  Future<PhoneLookupResponseDto> lookupPhone(
    @Body() PhoneLookupRequestDto request,
  );

  @POST(EndPoints.verifyFirstTimeOtp)
  Future<VerifyFirstTimeOtpResponseDto> verifyFirstTimeOtp(
    @Body() VerifyFirstTimeOtpRequestDto request,
  );

  @POST(EndPoints.setPassword)
  Future<StaffAuthResponseDto> setPassword(
    @Body() SetPasswordRequestDto request,
  );

  @POST(EndPoints.login)
  Future<StaffAuthResponseDto> login(
    @Body() StaffLoginRequestDto request,
  );

  @POST(EndPoints.forgotPassword)
  Future<StaffMessageResponseDto> forgotPassword(
    @Body() ForgotPasswordRequestDto request,
  );

  @POST(EndPoints.resetPassword)
  Future<StaffMessageResponseDto> resetPassword(
    @Body() ResetPasswordRequestDto request,
  );

  @POST(EndPoints.resendOtp)
  Future<StaffMessageResponseDto> resendOtp(
    @Body() ResendOtpRequestDto request,
  );

  @POST(EndPoints.refresh)
  Future<StaffAuthResponseDto> refreshToken(
    @Body() RefreshTokenRequestDto request,
  );

  // Driver-only registration and status endpoints
  @GET(EndPoints.driverRestaurants)
  Future<List<DriverRestaurantResponseDto>> getDriverRestaurants();

  @POST(EndPoints.driverRegistrationUpload)
  @MultiPart()
  Future<DriverFileUploadResponseDto> uploadDriverDocument(
    @Part(name: 'file') File file,
  );

  @POST(EndPoints.driverRegistration)
  Future<DriverRegistrationResponseDto> submitDriverRegistration(
    @Body() DriverRegistrationRequestDto request,
  );

  @GET(EndPoints.driverRegistrationStatus)
  Future<DriverRegistrationStatusResponseDto> getDriverRegistrationStatus({
    @Query('phone') String? phone,
    @Query('registrationId') String? registrationId,
  });

  @POST(EndPoints.driverRegistrationResubmit)
  Future<DriverRegistrationResponseDto> resubmitDriverRegistration(
    @Path('registrationId') String registrationId,
    @Body() DriverResubmitRequestDto request,
  );
}

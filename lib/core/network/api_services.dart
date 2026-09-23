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
import '../../features/auth/data/models/response/staff_role_response_dto.dart';
import '../../features/auth/data/models/response/verify_first_time_otp_response_dto.dart';
import '../../features/register/data/models/request/driver_registration_request_dto.dart';
import '../../features/register/data/models/request/driver_resubmit_request_dto.dart';
import '../../features/register/data/models/response/driver_file_upload_response_dto.dart';
import '../../features/register/data/models/response/driver_registration_response_dto.dart';
import '../../features/register/data/models/response/driver_restaurant_response_dto.dart';
import '../../features/register/data/models/response/driver_nationality_response_dto.dart';
import '../../features/register/data/models/response/driver_vehicle_color_response_dto.dart';
import '../../features/register/data/models/response/driver_vehicle_model_response_dto.dart';
import '../../features/register/data/models/response/driver_vehicle_type_response_dto.dart';
import '../../features/dispatcher/dispatcher_home/data/models/response/dispatcher_dashboard_overview_response_dto.dart';
import '../../features/dispatcher/dispatcher_home/data/models/response/dispatcher_live_driver_response_dto.dart';
import '../../features/dispatcher/dispatcher_orders/data/models/response/dispatcher_order_queue_response_dto.dart';
import '../../features/dispatcher/dispatcher_map/data/models/response/dispatcher_live_monitoring_response_dto.dart';
import '../../features/dispatcher/dispatcher_support/data/models/request/reassign_driver_request_dto.dart';
import '../../features/dispatcher/dispatcher_support/data/models/request/resolve_issue_request_dto.dart';
import '../../features/dispatcher/dispatcher_support/data/models/response/dispatcher_issue_details_response_dto.dart';
import '../../features/dispatcher/dispatcher_support/data/models/response/reassign_driver_candidates_response_dto.dart';
import '../../features/dispatcher/dispatcher_support/data/models/response/reassignment_response_dto.dart';
import '../../features/dispatcher/dispatcher_support/data/models/response/resolve_issue_response_dto.dart';
import '../../features/dispatcher/dispatcher_support/data/models/response/dispatcher_support_response_dto.dart';
import '../../features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_comparison_response_dto.dart';
import '../../features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_overview_response_dto.dart';
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
  Future<StaffAuthResponseDto> login(@Body() StaffLoginRequestDto request);

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

  @GET(EndPoints.staffRoles)
  Future<List<StaffRoleResponseDto>> getStaffRoles();

  // Driver-only registration and status endpoints
  @GET(EndPoints.driverRestaurants)
  Future<List<DriverRestaurantResponseDto>> getDriverRestaurants();

  @GET(EndPoints.driverNationalities)
  Future<List<DriverNationalityResponseDto>> getDriverNationalities();

  @GET(EndPoints.driverVehicleTypes)
  Future<List<DriverVehicleTypeResponseDto>> getDriverVehicleTypes();

  @GET(EndPoints.driverVehicleColors)
  Future<List<DriverVehicleColorResponseDto>> getDriverVehicleColors();

  @GET(EndPoints.driverVehicleModels)
  Future<List<DriverVehicleModelResponseDto>> searchDriverVehicleModels({
    @Query('search') String? search,
    @Query('vehicleType') String? vehicleType,
    @Query('limit') int limit = 40,
  });

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

  @GET(EndPoints.dispatcherDashboardOverview)
  Future<DispatcherDashboardOverviewResponseDto>
  getDispatcherDashboardOverview();

  @GET(EndPoints.dispatcherLiveLocations)
  Future<List<DispatcherLiveDriverResponseDto>> getDispatcherLiveLocations();

  @GET(EndPoints.dispatcherOrdersQueue)
  Future<DispatcherOrderQueueResponseDto> getDispatcherOrdersQueue(
    @Query('filter') String filter,
  );

  @GET(EndPoints.dispatcherLiveMonitoring)
  Future<DispatcherLiveMonitoringResponseDto> getDispatcherLiveMonitoring({
    @Query('restaurantId') String? restaurantId,
    @Query('status') String? status,
  });

  @GET(EndPoints.dispatcherSupportIssues)
  Future<DispatcherSupportResponseDto> getDispatcherSupportIssues({
    @Query('area') String? area,
    @Query('status') String? status,
    @Query('search') String? search,
    @Query('datePreset') String? datePreset,
    @Query('fromDateUtc') String? fromDateUtc,
    @Query('toDateUtc') String? toDateUtc,
    @Query('pageNumber') int? pageNumber,
    @Query('pageSize') int? pageSize,
  });

  @GET('${EndPoints.dispatcherSupportIssues}/{issueId}')
  Future<DispatcherIssueDetailsResponseDto> getDispatcherIssueDetails(
    @Path('issueId') String issueId,
  );

  @POST('${EndPoints.dispatcherSupportIssues}/{issueId}/resolve')
  Future<ResolveIssueResponseDto> resolveDispatcherIssue(
    @Path('issueId') String issueId,
    @Body() ResolveIssueRequestDto request,
  );

  @GET('${EndPoints.dispatcherSupportIssues}/{issueId}/candidates')
  Future<ReassignDriverCandidatesResponseDto> getReplacementDriverCandidates(
    @Path('issueId') String issueId,
    @Query('pageNumber') int pageNumber,
    @Query('pageSize') int pageSize,
  );

  @POST('${EndPoints.dispatcherSupportIssues}/{issueId}/reassign')
  Future<ReassignmentResponseDto> reassignDispatcherIssue(
    @Path('issueId') String issueId,
    @Body() ReassignDriverRequestDto request,
  );

  @GET(EndPoints.dispatcherPerformanceOverview)
  Future<DriverPerformanceOverviewResponseDto> getDriverPerformanceOverview({
    @Query('period') String? period,
    @Query('fromDate') String? fromDate,
    @Query('toDate') String? toDate,
  });

  @GET(EndPoints.dispatcherPerformanceComparison)
  Future<DriverPerformanceComparisonResponseDto> getDriverPerformanceComparison({
    @Query('period') String? period,
    @Query('driverIds') List<String>? driverIds,
    @Query('fromDate') String? fromDate,
    @Query('toDate') String? toDate,
  });
}

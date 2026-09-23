import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/shared_pref.dart';
import '../network/api_services.dart';
import '../network/network_constants.dart';
import '../services/auth_refresh_service.dart';
import '../services/device_id_service.dart';
import '../services/language_interceptor.dart';
import '../services/language_service.dart';
import '../services/token_interceptor.dart';
import '../services/token_service.dart';
import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repo/auth_repository_impl.dart';
import '../../features/auth/domain/repo/auth_repository.dart';
import '../../features/auth/domain/usecase/forgot_password_usecase.dart';
import '../../features/auth/domain/usecase/get_staff_roles_usecase.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/logout_usecase.dart';
import '../../features/auth/domain/usecase/lookup_phone_usecase.dart';
import '../../features/auth/domain/usecase/resend_otp_usecase.dart';
import '../../features/auth/domain/usecase/reset_password_usecase.dart';
import '../../features/auth/domain/usecase/restore_session_usecase.dart';
import '../../features/auth/domain/usecase/set_password_usecase.dart';
import '../../features/auth/domain/usecase/verify_first_time_otp_usecase.dart';
import '../../features/auth/presentation/manager/auth_view_model.dart';
import '../../features/account_status/data/data_source/account_status_remote_data_source.dart';
import '../../features/account_status/data/data_source/account_status_remote_data_source_impl.dart';
import '../../features/account_status/data/repo/account_status_repository_impl.dart';
import '../../features/account_status/domain/repo/account_status_repository.dart';
import '../../features/account_status/domain/usecase/get_account_status_usecase.dart';
import '../../features/account_status/presentation/manager/account_status_view_model.dart';
import '../../features/register/data/data_source/driver_registration_remote_data_source.dart';
import '../../features/register/data/data_source/driver_registration_remote_data_source_impl.dart';
import '../../features/register/data/repo/driver_registration_repository_impl.dart';
import '../../features/register/domain/repo/driver_registration_repository.dart';
import '../../features/register/domain/usecase/get_driver_restaurants_usecase.dart';
import '../../features/register/domain/usecase/get_driver_nationalities_usecase.dart';
import '../../features/register/domain/usecase/get_driver_vehicle_colors_usecase.dart';
import '../../features/register/domain/usecase/get_driver_vehicle_types_usecase.dart';
import '../../features/register/domain/usecase/resubmit_driver_registration_usecase.dart';
import '../../features/register/domain/usecase/search_driver_vehicle_models_usecase.dart';
import '../../features/register/domain/usecase/submit_driver_registration_usecase.dart';
import '../../features/register/domain/usecase/upload_driver_document_usecase.dart';
import '../../features/register/presentation/manager/driver_registration_view_model.dart';
import '../../features/dispatcher/dispatcher_home/data/data_source/dispatcher_home_remote_data_source.dart';
import '../../features/dispatcher/dispatcher_home/data/data_source/dispatcher_home_remote_data_source_impl.dart';
import '../../features/dispatcher/dispatcher_home/data/repo/dispatcher_home_repository_impl.dart';
import '../../features/dispatcher/dispatcher_home/domain/repo/dispatcher_home_repository.dart';
import '../../features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_home_overview_usecase.dart';
import '../../features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_live_drivers_usecase.dart';
import '../../features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_view_model.dart';
import '../../features/dispatcher/dispatcher_orders/data/data_source/dispatcher_orders_remote_data_source.dart';
import '../../features/dispatcher/dispatcher_orders/data/data_source/dispatcher_orders_remote_data_source_impl.dart';
import '../../features/dispatcher/dispatcher_orders/data/repo/dispatcher_orders_repository_impl.dart';
import '../../features/dispatcher/dispatcher_orders/domain/repo/dispatcher_orders_repository.dart';
import '../../features/dispatcher/dispatcher_orders/domain/usecase/get_dispatcher_order_queue_usecase.dart';
import '../../features/dispatcher/dispatcher_orders/presentation/manager/dispatcher_orders_view_model.dart';
import '../../features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source.dart';
import '../../features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source_impl.dart';
import '../../features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart';
import '../../features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_signalr_client.dart';
import '../../features/dispatcher/dispatcher_map/data/repo/dispatcher_map_repository_impl.dart';
import '../../features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart';
import '../../features/dispatcher/dispatcher_map/domain/usecase/get_dispatcher_live_monitoring_usecase.dart';
import '../../features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_connection_status_usecase.dart';
import '../../features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_updates_usecase.dart';
import '../../features/dispatcher/dispatcher_map/domain/usecase/start_dispatcher_map_updates_usecase.dart';
import '../../features/dispatcher/dispatcher_map/domain/usecase/stop_dispatcher_map_updates_usecase.dart';
import '../../features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model.dart';
import '../../features/dispatcher/dispatcher_support/data/data_source/dispatcher_support_remote_data_source.dart';
import '../../features/dispatcher/dispatcher_support/data/data_source/dispatcher_support_remote_data_source_impl.dart';
import '../../features/dispatcher/dispatcher_support/data/repo/dispatcher_support_repository_impl.dart';
import '../../features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import '../../features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_support_issues_usecase.dart';
import '../../features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_issue_details_usecase.dart';
import '../../features/dispatcher/dispatcher_support/domain/usecase/resolve_dispatcher_issue_usecase.dart';
import '../../features/dispatcher/dispatcher_support/domain/usecase/get_replacement_driver_candidates_usecase.dart';
import '../../features/dispatcher/dispatcher_support/domain/usecase/reassign_dispatcher_issue_usecase.dart';
import '../../features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_view_model.dart';
import '../../features/dispatcher/dispatcher_support/presentation/manager/issue_details/dispatcher_issue_details_view_model.dart';
import '../../features/dispatcher/dispatcher_support/presentation/manager/reassignment/dispatcher_reassignment_view_model.dart';
import '../../features/dispatcher/dispatcher_driver_performance/data/data_source/driver_performance_remote_data_source.dart';
import '../../features/dispatcher/dispatcher_driver_performance/data/data_source/driver_performance_remote_data_source_impl.dart';
import '../../features/dispatcher/dispatcher_driver_performance/data/repo/driver_performance_repository_impl.dart';
import '../../features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart';
import '../../features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart';
import '../../features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart';
import '../../features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model.dart';
import '../../features/dispatcher/dispatcher_operations/data/data_source/operations_log_remote_data_source.dart';
import '../../features/dispatcher/dispatcher_operations/data/data_source/operations_log_remote_data_source_impl.dart';
import '../../features/dispatcher/dispatcher_operations/data/repo/operations_log_repository_impl.dart';
import '../../features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart';
import '../../features/dispatcher/dispatcher_operations/domain/usecase/get_operations_log_usecase.dart';
import '../../features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<Dio>()) return;

  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  getIt.registerLazySingleton<SharedPrefHelper>(
    () => SharedPrefHelper(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<LanguageService>(
    () => LanguageService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<TokenService>(
    () => TokenService(
      secureStorage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<DeviceIdService>(
    () => DeviceIdService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<LanguageInterceptor>(
    () => LanguageInterceptor(getIt<LanguageService>()),
  );
  getIt.registerLazySingleton<TokenInterceptor>(
    () => TokenInterceptor(getIt<TokenService>()),
  );
  getIt.registerLazySingleton<Dio>(_buildDio);
  getIt.registerLazySingleton<AuthRefreshService>(
    () => AuthRefreshService(
      tokenService: getIt<TokenService>(),
      dio: getIt<Dio>(),
    ),
  );
  getIt.registerLazySingleton<ApiServices>(() => ApiServices(getIt<Dio>()));

  // Auth feature dependencies
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<TokenService>(),
    ),
  );
  getIt.registerFactory<LookupPhoneUseCase>(
    () => LookupPhoneUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<VerifyFirstTimeOtpUseCase>(
    () => VerifyFirstTimeOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SetPasswordUseCase>(
    () => SetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ResendOtpUseCase>(
    () => ResendOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<RestoreSessionUseCase>(
    () => RestoreSessionUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<GetStaffRolesUseCase>(
    () => GetStaffRolesUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      lookupPhoneUseCase: getIt<LookupPhoneUseCase>(),
      verifyFirstTimeOtpUseCase: getIt<VerifyFirstTimeOtpUseCase>(),
      setPasswordUseCase: getIt<SetPasswordUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
      resendOtpUseCase: getIt<ResendOtpUseCase>(),
      restoreSessionUseCase: getIt<RestoreSessionUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getStaffRolesUseCase: getIt<GetStaffRolesUseCase>(),
    ),
  );
  // Driver Registration feature dependencies
  getIt.registerLazySingleton<DriverRegistrationRemoteDataSource>(
    () => DriverRegistrationRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<DriverRegistrationRepository>(
    () => DriverRegistrationRepositoryImpl(
      getIt<DriverRegistrationRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<GetDriverRestaurantsUseCase>(
    () => GetDriverRestaurantsUseCase(getIt<DriverRegistrationRepository>()),
  );
  getIt.registerFactory<GetDriverNationalitiesUseCase>(
    () => GetDriverNationalitiesUseCase(getIt<DriverRegistrationRepository>()),
  );
  getIt.registerFactory<GetDriverVehicleTypesUseCase>(
    () => GetDriverVehicleTypesUseCase(getIt<DriverRegistrationRepository>()),
  );
  getIt.registerFactory<GetDriverVehicleColorsUseCase>(
    () => GetDriverVehicleColorsUseCase(getIt<DriverRegistrationRepository>()),
  );
  getIt.registerFactory<SearchDriverVehicleModelsUseCase>(
    () =>
        SearchDriverVehicleModelsUseCase(getIt<DriverRegistrationRepository>()),
  );
  getIt.registerFactory<UploadDriverDocumentUseCase>(
    () => UploadDriverDocumentUseCase(getIt<DriverRegistrationRepository>()),
  );
  getIt.registerFactory<SubmitDriverRegistrationUseCase>(
    () =>
        SubmitDriverRegistrationUseCase(getIt<DriverRegistrationRepository>()),
  );
  getIt.registerFactory<ResubmitDriverRegistrationUseCase>(
    () => ResubmitDriverRegistrationUseCase(
      getIt<DriverRegistrationRepository>(),
    ),
  );
  getIt.registerFactory<DriverRegistrationViewModel>(
    () => DriverRegistrationViewModel(
      getRestaurantsUseCase: getIt<GetDriverRestaurantsUseCase>(),
      getNationalitiesUseCase: getIt<GetDriverNationalitiesUseCase>(),
      getVehicleTypesUseCase: getIt<GetDriverVehicleTypesUseCase>(),
      getVehicleColorsUseCase: getIt<GetDriverVehicleColorsUseCase>(),
      searchVehicleModelsUseCase: getIt<SearchDriverVehicleModelsUseCase>(),
      uploadDocumentUseCase: getIt<UploadDriverDocumentUseCase>(),
      submitRegistrationUseCase: getIt<SubmitDriverRegistrationUseCase>(),
      resubmitRegistrationUseCase: getIt<ResubmitDriverRegistrationUseCase>(),
    ),
  );
  // Account Status feature dependencies
  getIt.registerLazySingleton<AccountStatusRemoteDataSource>(
    () => AccountStatusRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<AccountStatusRepository>(
    () => AccountStatusRepositoryImpl(getIt<AccountStatusRemoteDataSource>()),
  );
  getIt.registerFactory<GetAccountStatusUseCase>(
    () => GetAccountStatusUseCase(getIt<AccountStatusRepository>()),
  );
  getIt.registerFactory<AccountStatusViewModel>(
    () => AccountStatusViewModel(
      getAccountStatusUseCase: getIt<GetAccountStatusUseCase>(),
      lookupPhoneUseCase: getIt<LookupPhoneUseCase>(),
    ),
  );

  getIt.registerLazySingleton<DispatcherHomeRemoteDataSource>(
    () => DispatcherHomeRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<DispatcherHomeRepository>(
    () => DispatcherHomeRepositoryImpl(getIt<DispatcherHomeRemoteDataSource>()),
  );
  getIt.registerFactory<GetDispatcherHomeOverviewUseCase>(
    () => GetDispatcherHomeOverviewUseCase(getIt<DispatcherHomeRepository>()),
  );
  getIt.registerFactory<GetDispatcherLiveDriversUseCase>(
    () => GetDispatcherLiveDriversUseCase(getIt<DispatcherHomeRepository>()),
  );
  getIt.registerFactory<DispatcherHomeViewModel>(
    () => DispatcherHomeViewModel(
      getOverviewUseCase: getIt<GetDispatcherHomeOverviewUseCase>(),
      getLiveDriversUseCase: getIt<GetDispatcherLiveDriversUseCase>(),
    ),
  );

  // Dispatcher Orders feature dependencies
  getIt.registerLazySingleton<DispatcherOrdersRemoteDataSource>(
    () => DispatcherOrdersRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<DispatcherOrdersRepository>(
    () => DispatcherOrdersRepositoryImpl(
      getIt<DispatcherOrdersRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<GetDispatcherOrderQueueUseCase>(
    () => GetDispatcherOrderQueueUseCase(getIt<DispatcherOrdersRepository>()),
  );
  getIt.registerFactory<DispatcherOrdersViewModel>(
    () => DispatcherOrdersViewModel(
      getQueueUseCase: getIt<GetDispatcherOrderQueueUseCase>(),
    ),
  );

  // Dispatcher Map feature dependencies
  getIt.registerLazySingleton<DispatcherMapRealtimeClient>(
    () => DispatcherMapSignalRClient(
      getIt<TokenService>(),
      refreshService: getIt<AuthRefreshService>(),
    ),
  );
  getIt.registerLazySingleton<DispatcherMapRemoteDataSource>(
    () => DispatcherMapRemoteDataSourceImpl(
      getIt<ApiServices>(),
      getIt<DispatcherMapRealtimeClient>(),
    ),
  );
  getIt.registerLazySingleton<DispatcherMapRepository>(
    () => DispatcherMapRepositoryImpl(getIt<DispatcherMapRemoteDataSource>()),
  );
  getIt.registerFactory<GetDispatcherLiveMonitoringUseCase>(
    () => GetDispatcherLiveMonitoringUseCase(getIt<DispatcherMapRepository>()),
  );
  getIt.registerFactory<ObserveDispatcherMapUpdatesUseCase>(
    () => ObserveDispatcherMapUpdatesUseCase(getIt<DispatcherMapRepository>()),
  );
  getIt.registerFactory<ObserveDispatcherMapConnectionStatusUseCase>(
    () => ObserveDispatcherMapConnectionStatusUseCase(
      getIt<DispatcherMapRepository>(),
    ),
  );
  getIt.registerFactory<StartDispatcherMapUpdatesUseCase>(
    () => StartDispatcherMapUpdatesUseCase(getIt<DispatcherMapRepository>()),
  );
  getIt.registerFactory<StopDispatcherMapUpdatesUseCase>(
    () => StopDispatcherMapUpdatesUseCase(getIt<DispatcherMapRepository>()),
  );
  getIt.registerFactory<DispatcherMapViewModel>(
    () => DispatcherMapViewModel(
      getLiveMonitoringUseCase: getIt<GetDispatcherLiveMonitoringUseCase>(),
      observeUpdatesUseCase: getIt<ObserveDispatcherMapUpdatesUseCase>(),
      observeConnectionStatusUseCase:
          getIt<ObserveDispatcherMapConnectionStatusUseCase>(),
      startUpdatesUseCase: getIt<StartDispatcherMapUpdatesUseCase>(),
      stopUpdatesUseCase: getIt<StopDispatcherMapUpdatesUseCase>(),
    ),
  );

  // Dispatcher support feature dependencies
  getIt.registerLazySingleton<DispatcherSupportRemoteDataSource>(
    () => DispatcherSupportRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<DispatcherSupportRepository>(
    () => DispatcherSupportRepositoryImpl(
      getIt<DispatcherSupportRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<GetDispatcherSupportIssuesUseCase>(
    () =>
        GetDispatcherSupportIssuesUseCase(getIt<DispatcherSupportRepository>()),
  );
  getIt.registerFactory<GetDispatcherIssueDetailsUseCase>(
    () =>
        GetDispatcherIssueDetailsUseCase(getIt<DispatcherSupportRepository>()),
  );
  getIt.registerFactory<ResolveDispatcherIssueUseCase>(
    () => ResolveDispatcherIssueUseCase(getIt<DispatcherSupportRepository>()),
  );
  getIt.registerFactory<GetReplacementDriverCandidatesUseCase>(
    () => GetReplacementDriverCandidatesUseCase(
      getIt<DispatcherSupportRepository>(),
    ),
  );
  getIt.registerFactory<ReassignDispatcherIssueUseCase>(
    () => ReassignDispatcherIssueUseCase(getIt<DispatcherSupportRepository>()),
  );
  getIt.registerFactory<DispatcherSupportViewModel>(
    () => DispatcherSupportViewModel(
      getIssuesUseCase: getIt<GetDispatcherSupportIssuesUseCase>(),
    ),
  );
  getIt.registerFactoryParam<DispatcherIssueDetailsViewModel, String, void>(
    (issueId, _) => DispatcherIssueDetailsViewModel(
      issueId: issueId,
      getDetailsUseCase: getIt<GetDispatcherIssueDetailsUseCase>(),
      resolveUseCase: getIt<ResolveDispatcherIssueUseCase>(),
    ),
  );
  getIt.registerFactoryParam<DispatcherReassignmentViewModel, String, void>(
    (issueId, _) => DispatcherReassignmentViewModel(
      issueId: issueId,
      getCandidatesUseCase: getIt<GetReplacementDriverCandidatesUseCase>(),
      reassignUseCase: getIt<ReassignDispatcherIssueUseCase>(),
    ),
  );

  // Dispatcher Driver Performance
  getIt.registerLazySingleton<DriverPerformanceRemoteDataSource>(
    () => DriverPerformanceRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<DriverPerformanceRepository>(
    () => DriverPerformanceRepositoryImpl(
      getIt<DriverPerformanceRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<GetDriverPerformanceOverviewUseCase>(
    () => GetDriverPerformanceOverviewUseCase(
      getIt<DriverPerformanceRepository>(),
    ),
  );
  getIt.registerFactory<GetDriverPerformanceComparisonUseCase>(
    () => GetDriverPerformanceComparisonUseCase(
      getIt<DriverPerformanceRepository>(),
    ),
  );
  getIt.registerFactory<DriverPerformanceViewModel>(
    () => DriverPerformanceViewModel(
      getOverviewUseCase: getIt<GetDriverPerformanceOverviewUseCase>(),
      getComparisonUseCase: getIt<GetDriverPerformanceComparisonUseCase>(),
    ),
  );

  // Dispatcher Operations Log
  getIt.registerLazySingleton<OperationsLogRemoteDataSource>(
    () => OperationsLogRemoteDataSourceImpl(getIt<ApiServices>()),
  );
  getIt.registerLazySingleton<OperationsLogRepository>(
    () => OperationsLogRepositoryImpl(
      getIt<OperationsLogRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<GetOperationsLogUseCase>(
    () => GetOperationsLogUseCase(
      getIt<OperationsLogRepository>(),
    ),
  );
  getIt.registerFactory<OperationsViewModel>(
    () => OperationsViewModel(
      getOperationsLogUseCase: getIt<GetOperationsLogUseCase>(),
    ),
  );
}

Dio _buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: NetworkConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final tokenInterceptor = getIt<TokenInterceptor>();
  dio.interceptors.add(getIt<LanguageInterceptor>());
  dio.interceptors.add(tokenInterceptor);
  dio.interceptors.add(PrettyDioLogger(requestHeader: true, requestBody: true));

  tokenInterceptor.attachRefreshService(
    AuthRefreshService(tokenService: getIt<TokenService>(), dio: dio),
  );

  return dio;
}

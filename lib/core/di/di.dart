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
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/logout_usecase.dart';
import '../../features/auth/domain/usecase/lookup_phone_usecase.dart';
import '../../features/auth/domain/usecase/resend_otp_usecase.dart';
import '../../features/auth/domain/usecase/reset_password_usecase.dart';
import '../../features/auth/domain/usecase/restore_session_usecase.dart';
import '../../features/auth/domain/usecase/set_password_usecase.dart';
import '../../features/auth/domain/usecase/verify_first_time_otp_usecase.dart';
import '../../features/auth/presentation/manager/auth_view_model.dart';

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
    AuthRefreshService(
      tokenService: getIt<TokenService>(),
      dio: dio,
    ),
  );

  return dio;
}

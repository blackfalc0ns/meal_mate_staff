import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/shared_pref.dart';
import '../network/api_services.dart';
import '../network/network_constants.dart';
import '../services/device_id_service.dart';
import '../services/language_interceptor.dart';
import '../services/language_service.dart';
import '../services/token_interceptor.dart';
import '../services/token_service.dart';

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
  getIt.registerLazySingleton<ApiServices>(() => ApiServices(getIt<Dio>()));
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

  dio.interceptors.add(getIt<LanguageInterceptor>());
  dio.interceptors.add(getIt<TokenInterceptor>());
  dio.interceptors.add(PrettyDioLogger(requestHeader: true, requestBody: true));

  return dio;
}

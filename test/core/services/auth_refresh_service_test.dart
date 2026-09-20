import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/network_constants.dart';
import 'package:meal_mate_delivery/core/services/auth_refresh_service.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenService tokenService;
  late Dio dio;
  late AuthRefreshService refreshService;
  int httpCallCount = 0;

  setUp(() async {
    httpCallCount = 0;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    tokenService = TokenService(
      secureStorage: secureStorage,
      sharedPreferences: prefs,
    );

    dio = Dio(BaseOptions(baseUrl: NetworkConstants.baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path == EndPoints.refresh) {
            httpCallCount++;
            // Simulate slight delay to test concurrency
            await Future.delayed(const Duration(milliseconds: 50));
            final reqData = options.data as Map<String, dynamic>?;
            if (reqData?['refreshToken'] == 'valid_refresh') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'accessToken': 'new_access_token',
                    'refreshToken': 'new_refresh_token',
                  },
                ),
              );
              return;
            } else {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 401,
                  ),
                ),
              );
              return;
            }
          }
          handler.next(options);
        },
      ),
    );

    refreshService = AuthRefreshService(
      tokenService: tokenService,
      dio: dio,
    );
  });

  group('AuthRefreshService Tests', () {
    test('concurrent refreshToken calls share single HTTP request', () async {
      await tokenService.saveRefreshToken('valid_refresh');

      // Launch 3 simultaneous refresh calls
      final results = await Future.wait([
        refreshService.refreshToken(),
        refreshService.refreshToken(),
        refreshService.refreshToken(),
      ]);

      expect(httpCallCount, 1);
      expect(results[0], 'new_access_token');
      expect(results[1], 'new_access_token');
      expect(results[2], 'new_access_token');

      expect(await tokenService.getToken(), 'new_access_token');
      expect(await tokenService.getRefreshToken(), 'new_refresh_token');
    });

    test('failed refresh clears tokens and returns null', () async {
      await tokenService.saveAccessToken('old_access');
      await tokenService.saveRefreshToken('invalid_refresh');

      final result = await refreshService.refreshToken();

      expect(result, isNull);
      expect(await tokenService.getToken(), isNull);
      expect(await tokenService.getRefreshToken(), isNull);
    });

    test('returns null immediately if no refresh token saved', () async {
      final result = await refreshService.refreshToken();
      expect(result, isNull);
      expect(httpCallCount, 0);
    });
  });
}

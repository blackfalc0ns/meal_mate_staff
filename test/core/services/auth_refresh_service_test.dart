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
                    data: {'code': 'auth.invalid_refresh_token'},
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

    refreshService = AuthRefreshService(tokenService: tokenService, dio: dio);
  });

  for (final status in [429, 500, 503]) {
    test('transient refresh HTTP $status retains both credentials', () async {
      await tokenService.saveAccessToken('old_access');
      await tokenService.saveRefreshToken('valid_refresh');
      final failingDio = Dio();
      failingDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: status),
              ),
            );
          },
        ),
      );
      final service = AuthRefreshService(
        tokenService: tokenService,
        dio: failingDio,
      );
      expect(await service.refreshToken(), isNull);
      expect(await tokenService.getToken(), 'old_access');
      expect(await tokenService.getRefreshToken(), 'valid_refresh');
    });
  }

  test('proactively refreshes inside the two-minute window', () async {
    final now = DateTime.utc(2026, 10, 23, 12);
    await tokenService.saveTokenPair(
      accessToken: 'near_expiry',
      refreshToken: 'valid_refresh',
      accessTokenExpiresAtUtc: now
          .add(const Duration(seconds: 119))
          .toIso8601String(),
    );
    final service = AuthRefreshService(
      tokenService: tokenService,
      dio: dio,
      now: () => now,
    );
    expect(await service.ensureFreshToken(), 'new_access_token');
    expect(httpCallCount, 1);
  });

  test('late unauthorized response reuses already rotated token', () async {
    await tokenService.saveAccessToken('old');
    await tokenService.saveRefreshToken('valid_refresh');
    await refreshService.refreshToken();
    expect(
      await refreshService.refreshToken(rejectedAccessToken: 'old'),
      'new_access_token',
    );
    expect(httpCallCount, 1);
  });

  for (final code in [
    'auth.account_suspended',
    'auth.account_closed',
    'family.password_setup_required',
  ]) {
    test('definitive $code cleans up before clearing and navigating', () async {
      await tokenService.saveAccessToken('old');
      await tokenService.saveRefreshToken('valid_refresh');
      final events = <String>[];
      final client = Dio();
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 403,
                  data: {'code': code},
                ),
              ),
            );
          },
        ),
      );
      final service = AuthRefreshService(
        tokenService: tokenService,
        dio: client,
        onSessionRejected: (reason) async {
          expect(await tokenService.getToken(), 'old');
          events.add('cleanup');
        },
      );
      service.onReauthenticate = (reason) {
        expect(reason, code);
        events.add('navigate');
      };
      expect(await service.refreshToken(), isNull);
      expect(await tokenService.getToken(), isNull);
      expect(events, ['cleanup', 'navigate']);
    });
  }

  test(
    'timeout retains session and bounds repeated refresh attempts',
    () async {
      await tokenService.saveAccessToken('old');
      await tokenService.saveRefreshToken('valid_refresh');
      final client = Dio();
      var calls = 0;
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.receiveTimeout,
              ),
            );
          },
        ),
      );
      final service = AuthRefreshService(
        tokenService: tokenService,
        dio: client,
      );
      await service.refreshToken();
      await service.refreshToken();
      expect(calls, 1);
      expect(await tokenService.getRefreshToken(), 'valid_refresh');
    },
  );

  test('logout while refresh is in flight cannot restore old login', () async {
    await tokenService.saveAccessToken('old');
    await tokenService.saveRefreshToken('valid_refresh');
    final operation = refreshService.refreshToken();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await tokenService.clearTokens();
    expect(await operation, isNull);
    expect(await tokenService.getToken(), isNull);
  });

  test(
    'network recovery retries after cooldown without losing the session',
    () async {
      var now = DateTime.utc(2026, 10, 23, 12);
      await tokenService.saveTokenPair(
        accessToken: 'expired',
        refreshToken: 'valid_refresh',
        accessTokenExpiresAtUtc: now
            .subtract(const Duration(seconds: 1))
            .toIso8601String(),
      );
      final client = Dio();
      var calls = 0;
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            if (calls == 1) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'accessToken': 'recovered', 'refreshToken': 'rotated'},
                ),
              );
            }
          },
        ),
      );
      final service = AuthRefreshService(
        tokenService: tokenService,
        dio: client,
        now: () => now,
      );
      expect(await service.ensureFreshToken(), isNull);
      expect(await tokenService.getRefreshToken(), 'valid_refresh');
      now = now.add(const Duration(seconds: 16));
      expect(await service.ensureFreshToken(), 'recovered');
      expect(calls, 2);
    },
  );

  test(
    'proactive transient failure still permits an unexpired token',
    () async {
      final now = DateTime.utc(2026, 10, 23, 12);
      await tokenService.saveTokenPair(
        accessToken: 'valid',
        refreshToken: 'valid_refresh',
        accessTokenExpiresAtUtc: now
            .add(const Duration(seconds: 100))
            .toIso8601String(),
      );
      final client = Dio();
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
      final service = AuthRefreshService(
        tokenService: tokenService,
        dio: client,
        now: () => now,
      );
      expect(await service.ensureFreshToken(), 'valid');
      expect(await tokenService.getRefreshToken(), 'valid_refresh');
    },
  );

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

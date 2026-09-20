import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/network_constants.dart';
import 'package:meal_mate_delivery/core/services/auth_refresh_service.dart';
import 'package:meal_mate_delivery/core/services/token_interceptor.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClientAdapter implements HttpClientAdapter {
  MockHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenService tokenService;
  late Dio dio;
  late TokenInterceptor tokenInterceptor;
  int protectedEndpointCalls = 0;

  setUp(() async {
    protectedEndpointCalls = 0;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    tokenService = TokenService(
      secureStorage: secureStorage,
      sharedPreferences: prefs,
    );

    dio = Dio(BaseOptions(baseUrl: NetworkConstants.baseUrl));
    tokenInterceptor = TokenInterceptor(tokenService);

    final refreshService = AuthRefreshService(
      tokenService: tokenService,
      dio: dio,
    );

    tokenInterceptor.attachRefreshService(refreshService);
    dio.interceptors.add(tokenInterceptor);

    dio.httpClientAdapter = MockHttpClientAdapter((options) async {
      if (options.path == EndPoints.refresh ||
          options.path.endsWith(EndPoints.refresh)) {
        return ResponseBody.fromString(
          jsonEncode({
            'accessToken': 'refreshed_access_token',
            'refreshToken': 'refreshed_refresh_token',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }

      if (options.path == '/protected' || options.path.endsWith('/protected')) {
        protectedEndpointCalls++;
        final authHeader = options.headers[NetworkConstants.authorization];
        if (authHeader == 'Bearer refreshed_access_token') {
          return ResponseBody.fromString(
            jsonEncode({'success': true}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else {
          return ResponseBody.fromString(
            jsonEncode({'error': 'Unauthorized'}),
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
      }

      return ResponseBody.fromString(
        jsonEncode({'ok': true}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
  });

  group('TokenInterceptor Tests', () {
    test('adds Bearer token when access token is saved', () async {
      await tokenService.saveAccessToken('initial_token');
      RequestOptions? captured;

      final testDio = Dio(BaseOptions(baseUrl: NetworkConstants.baseUrl));
      testDio.interceptors.add(TokenInterceptor(tokenService));
      testDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        captured = options;
        return ResponseBody.fromString('{}', 200);
      });

      await testDio.get('/test');
      expect(
        captured?.headers[NetworkConstants.authorization],
        'Bearer initial_token',
      );
    });

    test('skips authorization header when skipAuth is true', () async {
      await tokenService.saveAccessToken('initial_token');
      RequestOptions? captured;

      final testDio = Dio(BaseOptions(baseUrl: NetworkConstants.baseUrl));
      testDio.interceptors.add(TokenInterceptor(tokenService));
      testDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        captured = options;
        return ResponseBody.fromString('{}', 200);
      });

      await testDio.get(
        '/public',
        options: Options(extra: {TokenInterceptor.skipAuthKey: true}),
      );
      expect(captured?.headers[NetworkConstants.authorization], isNull);
    });

    test('on 401 triggers refresh and retries request successfully', () async {
      await tokenService.saveAccessToken('expired_token');
      await tokenService.saveRefreshToken('valid_refresh_token');

      final response = await dio.get('/protected');

      expect(response.statusCode, 200);
      expect(response.data['success'], isTrue);
      expect(protectedEndpointCalls, 2); // Initial attempt + retry
      expect(await tokenService.getToken(), 'refreshed_access_token');
    });

    test('does not loop recursively if retry fails with 401', () async {
      await tokenService.saveAccessToken('expired_token');
      try {
        await dio.get('/protected');
        fail('Expected DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
        expect(protectedEndpointCalls, 1);
      }
    });
  });
}

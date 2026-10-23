import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/core/services/token_interceptor.dart';
import 'package:meal_mate_delivery/core/services/auth_refresh_service.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handle);
  final Future<ResponseBody> Function(RequestOptions) handle;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) => handle(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, dynamic> data) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TokenService tokens;
  late Dio client;
  late AuthRefreshService service;
  var rotations = 0;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    tokens = TokenService(
      secureStorage: const FlutterSecureStorage(),
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    await tokens.saveTokenPair(accessToken: 'old', refreshToken: 'refresh-old');
    rotations = 0;
    final refreshClient = Dio(BaseOptions(baseUrl: 'https://example.test'));
    refreshClient.httpClientAdapter = _Adapter((options) async {
      rotations++;
      expect(options.headers['Authorization'], isNull);
      expect(options.data, {'refreshToken': 'refresh-old'});
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return _json(200, {'accessToken': 'new', 'refreshToken': 'refresh-new'});
    });
    service = AuthRefreshService(tokenService: tokens, dio: refreshClient);
    client = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final interceptor = TokenInterceptor(tokens, service)..requestDio = client;
    client.interceptors.add(interceptor);
  });

  test(
    'concurrent 401 requests rotate once and replay with latest token',
    () async {
      var requests = 0;
      client.httpClientAdapter = _Adapter((options) async {
        requests++;
        return options.headers['Authorization'] == 'Bearer old'
            ? _json(401, {})
            : _json(200, {'ok': true});
      });
      final results = await Future.wait(
        List.generate(6, (_) => client.get('/protected')),
      );
      expect(results.every((result) => result.statusCode == 200), isTrue);
      expect(rotations, 1);
      expect(requests, 12);
      expect(await tokens.getRefreshToken(), 'refresh-new');
    },
  );

  test(
    '409 replays initiate with identical operation key and owned voice proof',
    () async {
      final bodies = <dynamic>[];
      final proofs = <dynamic>[];
      client.httpClientAdapter = _Adapter((options) async {
        bodies.add(Map.of(options.data as Map));
        proofs.add(options.headers['X-Voice-Device-Proof']);
        return bodies.length == 1
            ? _json(409, {'code': 'calls.auth_refresh_required'})
            : _json(200, {'callId': 'one-call'});
      });
      final response = await client.post(
        '/api/v2/voice-calls/initiate',
        data: {'tripStopId': 'stop', 'clientRequestId': 'same-key'},
        options: Options(
          headers: {
            'X-Voice-Device-Session': 'owned-session',
            'X-Voice-Device-Proof': 'owned-proof',
          },
        ),
      );
      expect(response.data['callId'], 'one-call');
      expect(bodies, [
        {'tripStopId': 'stop', 'clientRequestId': 'same-key'},
        {'tripStopId': 'stop', 'clientRequestId': 'same-key'},
      ]);
      expect(proofs, ['owned-proof', 'owned-proof']);
      expect(rotations, 1);
    },
  );

  test(
    'second 401 after rotation stops retrying without clearing login',
    () async {
      var requests = 0;
      client.httpClientAdapter = _Adapter((options) async {
        requests++;
        return _json(401, {});
      });
      await expectLater(client.get('/protected'), throwsA(isA<DioException>()));
      expect(requests, 2);
      expect(rotations, 1);
      expect(await tokens.getToken(), 'new');
    },
  );

  test('ordinary conflict never refreshes', () async {
    client.httpClientAdapter = _Adapter(
      (options) async => _json(409, {'code': 'calls.busy'}),
    );
    await expectLater(
      client.post('/api/v2/voice-calls/initiate'),
      throwsA(isA<DioException>()),
    );
    expect(rotations, 0);
  });
}

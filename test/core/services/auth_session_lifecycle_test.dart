import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/core/services/auth_refresh_service.dart';
import 'package:meal_mate_delivery/core/services/auth_session_lifecycle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'resume refreshes expired access and reconciles without local cleanup',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final tokens = TokenService(
        secureStorage: const FlutterSecureStorage(),
        sharedPreferences: await SharedPreferences.getInstance(),
      );
      var now = DateTime.utc(2026, 10, 23, 12);
      await tokens.saveTokenPair(
        accessToken: 'valid',
        refreshToken: 'refresh',
        accessTokenExpiresAtUtc: now
            .add(const Duration(minutes: 10))
            .toIso8601String(),
      );
      final dio = Dio();
      var refreshes = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            refreshes++;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'accessToken': 'renewed',
                  'refreshToken': 'rotated',
                  'accessTokenExpiresAtUtc': now
                      .add(const Duration(minutes: 10))
                      .toIso8601String(),
                },
              ),
            );
          },
        ),
      );
      var reconciliations = 0;
      var cleanups = 0;
      final service = AuthRefreshService(
        tokenService: tokens,
        dio: dio,
        now: () => now,
      );
      final lifecycle = AuthSessionLifecycle(
        refresh: service,
        tokens: tokens,
        cleanupLocalCall: () async {
          cleanups++;
        },
        reconcileCall: () async {
          reconciliations++;
        },
      );
      lifecycle.start();
      addTearDown(lifecycle.dispose);
      await tester.pumpAndSettle();
      expect(refreshes, 0);
      now = now.add(const Duration(minutes: 11));
      lifecycle.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(refreshes, 1);
      expect(reconciliations, 1);
      expect(cleanups, 0);
      expect(await tokens.getToken(), 'renewed');
      lifecycle.dispose();
    },
  );
}

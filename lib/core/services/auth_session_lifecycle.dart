import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/routing/app_routes.dart';
import 'app_navigator_service.dart';
import 'auth_refresh_service.dart';
import 'token_service.dart';

/// Requests and native reconnects also check expiry; timers are only an extra trigger.
class AuthSessionLifecycle with WidgetsBindingObserver {
  AuthSessionLifecycle({
    required this.refresh,
    required this.tokens,
    required this.cleanupLocalCall,
    required this.reconcileCall,
  });

  final AuthRefreshService refresh;
  final TokenService tokens;
  final Future<void> Function() cleanupLocalCall;
  final Future<void> Function() reconcileCall;
  static const _channel = MethodChannel('mealmate/auth_session');
  Timer? _timer;
  bool _checking = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    refresh.onTokensChanged = (access, credential) async {
      if (Platform.isAndroid) {
        await _channel.invokeMethod<void>('syncTokens', {
          'accessToken': access,
          'refreshToken': credential,
        });
      }
    };
    refresh.onSessionRejected = (_) async {
      try {
        if (Platform.isAndroid) {
          await _channel.invokeMethod<void>('terminateLocal');
        }
      } finally {
        await cleanupLocalCall();
      }
    };
    refresh.onReauthenticate = (code) {
      final nav = AppNavigatorService.navigator;
      if (nav == null) return;
      final message = switch (code) {
        'auth.account_suspended' => 'الحساب موقوف. تواصل مع الدعم.',
        'auth.account_closed' => 'الحساب مغلق.',
        'family.password_setup_required' => 'يلزم إكمال إعداد كلمة المرور.',
        _ => 'انتهت جلسة تسجيل الدخول. سجّل الدخول مرة أخرى.',
      };
      final context = AppNavigatorService.context;
      if (context != null) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(message)));
      }
      // The family flow requires a verification credential; restart login to obtain it.
      unawaited(nav.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false));
    };
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler((call) async {
        if (call.method != 'getToken') throw MissingPluginException();
        final args = call.arguments as Map?;
        final token = args?['force'] == true
            ? await refresh.refreshToken(
                rejectedAccessToken: args?['rejectedToken'] as String?,
              )
            : await refresh.ensureFreshToken();
        // Also resync on startup/resume, not only after a rotation.
        if (token == null) return null;
        final pair = await tokens.getTokenPair();
        if (pair.accessToken != null && pair.refreshToken != null) {
          await refresh.onTokensChanged?.call(
            pair.accessToken!,
            pair.refreshToken!,
          );
        }
        return pair.accessToken;
      });
      unawaited(
        _channel.invokeMethod<void>('activate').catchError((Object _) {}),
      );
    }
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(check()),
    );
    unawaited(check());
  }

  Future<void> check({bool reconcile = false}) async {
    if (_checking) return;
    _checking = true;
    try {
      if (await refresh.ensureFreshToken() != null && reconcile) {
        if (Platform.isAndroid) await _channel.invokeMethod<void>('reconcile');
        await reconcileCall();
      }
    } catch (_) {
      // Resume/network/bridge errors are transient, never a reason to log out.
    } finally {
      _checking = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(check(reconcile: true));
  }

  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isAndroid) _channel.setMethodCallHandler(null);
  }
}

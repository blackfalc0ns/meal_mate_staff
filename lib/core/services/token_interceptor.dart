import 'dart:async';

import 'package:dio/dio.dart';

import '../../config/routing/app_routes.dart';
import '../network/network_constants.dart';
import 'app_navigator_service.dart';
import 'auth_refresh_service.dart';
import 'token_service.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor(
    this._tokenService, [
    this._refreshService,
    this._onSessionExpired,
  ]);

  static const String skipAuthKey = 'skipAuth';
  static const String isRetryKey = 'isRetry';

  final TokenService _tokenService;
  AuthRefreshService? _refreshService;
  final void Function()? _onSessionExpired;
  bool _isRedirecting = false;
  Dio? requestDio;

  void attachRefreshService(AuthRefreshService refreshService) {
    _refreshService = refreshService;
  }

  void _redirectToLogin() {
    if (_isRedirecting) return;
    _isRedirecting = true;
    if (_onSessionExpired != null) {
      _onSessionExpired();
    } else {
      final nav = AppNavigatorService.navigator;
      if (nav != null) {
        unawaited(
          nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
        );
      }
    }
    Future.delayed(const Duration(seconds: 2), () {
      _isRedirecting = false;
    });
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true ||
        options.path == EndPoints.refresh) {
      options.headers.remove(NetworkConstants.authorization);
      handler.next(options);
      return;
    }

    final token = _refreshService != null && options.extra[isRetryKey] != true
        ? await _refreshService!.ensureFreshToken()
        : await _tokenService.getToken();
    if (token == null &&
        await _tokenService.getToken() != null &&
        _refreshService != null) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Session renewal temporarily unavailable',
        ),
      );
      return;
    }
    if (token != null && token.isNotEmpty) {
      options.headers[NetworkConstants.authorization] =
          '${NetworkConstants.bearer} $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final data = err.response?.data;
    final code = data is Map
        ? (data['code'] ??
              (data['extensions'] is Map ? data['extensions']['code'] : null))
        : null;
    final requiresRefresh =
        err.response?.statusCode == 401 ||
        (err.response?.statusCode == 409 &&
            code == 'calls.auth_refresh_required' &&
            err.requestOptions.uri.path.endsWith(
              EndPoints.voiceCallsV2Initiate,
            ));
    final options = err.requestOptions;
    if (requiresRefresh &&
        options.extra[isRetryKey] != true &&
        !options.uri.path.endsWith(EndPoints.refresh) &&
        options.extra[skipAuthKey] != true &&
        _refreshService != null) {
      final authorization = options.headers[NetworkConstants.authorization]
          ?.toString();
      final rejected = authorization?.replaceFirst(
        RegExp(r'^Bearer\s+', caseSensitive: false),
        '',
      );
      final newToken = await _refreshService!.refreshToken(
        rejectedAccessToken: rejected,
      );
      if (newToken != null) {
        final retry = options.copyWith(
          headers: {
            ...options.headers,
            NetworkConstants.authorization:
                '${NetworkConstants.bearer} $newToken',
          },
          extra: {...options.extra, isRetryKey: true},
          data: options.data is FormData
              ? (options.data as FormData).clone()
              : options.data,
        );
        try {
          final response = await (requestDio ?? _refreshService!.dio)
              .fetch<dynamic>(retry);
          handler.resolve(response);
        } on DioException catch (error) {
          handler.next(error);
        } catch (_) {
          handler.next(err);
        }
        return;
      }
      if (_refreshService!.terminalCode != null &&
          _refreshService!.onSessionRejected == null) {
        _redirectToLogin();
      }
    }
    handler.next(err);
  }
}

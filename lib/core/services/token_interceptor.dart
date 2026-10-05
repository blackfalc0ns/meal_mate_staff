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
          nav.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          ),
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

    final token = await _tokenService.getToken();
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
    final isUnauthorized = err.response?.statusCode == 401;
    final isRetry = err.requestOptions.extra[isRetryKey] == true;
    final isRefreshEndpoint = err.requestOptions.path == EndPoints.refresh;
    final isSkipAuth = err.requestOptions.extra[skipAuthKey] == true;

    if (isUnauthorized &&
        !isRetry &&
        !isRefreshEndpoint &&
        !isSkipAuth) {
      if (_refreshService != null) {
        final newToken = await _refreshService!.refreshToken();
        if (newToken != null && newToken.isNotEmpty) {
          final requestOptions = err.requestOptions;
          requestOptions.extra[isRetryKey] = true;
          requestOptions.headers[NetworkConstants.authorization] =
              '${NetworkConstants.bearer} $newToken';

          try {
            final response = await _refreshService!.dio.fetch(requestOptions);
            handler.resolve(response);
            return;
          } on DioException catch (retryError) {
            if (retryError.response?.statusCode == 401) {
              await _tokenService.clearTokens();
              _redirectToLogin();
            }
            handler.next(retryError);
            return;
          } catch (_) {
            handler.next(err);
            return;
          }
        }
      }

      await _tokenService.clearTokens();
      _redirectToLogin();
    }

    handler.next(err);
  }
}


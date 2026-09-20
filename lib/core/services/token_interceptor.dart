import 'package:dio/dio.dart';

import '../network/network_constants.dart';
import 'auth_refresh_service.dart';
import 'token_service.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor(this._tokenService, [this._refreshService]);

  static const String skipAuthKey = 'skipAuth';
  static const String isRetryKey = 'isRetry';

  final TokenService _tokenService;
  AuthRefreshService? _refreshService;

  void attachRefreshService(AuthRefreshService refreshService) {
    _refreshService = refreshService;
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
        !isSkipAuth &&
        _refreshService != null) {
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
          handler.next(retryError);
          return;
        } catch (_) {
          handler.next(err);
          return;
        }
      }
    }

    handler.next(err);
  }
}

import 'package:dio/dio.dart';

import '../network/network_constants.dart';
import 'token_service.dart';

class TokenInterceptor extends QueuedInterceptor {
  TokenInterceptor(this._tokenService);

  static const String skipAuthKey = 'skipAuth';

  final TokenService _tokenService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true) {
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
}

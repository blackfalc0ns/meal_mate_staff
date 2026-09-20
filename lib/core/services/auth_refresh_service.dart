import 'package:dio/dio.dart';

import '../network/network_constants.dart';
import 'token_interceptor.dart';
import 'token_service.dart';

class AuthRefreshService {
  AuthRefreshService({
    required TokenService tokenService,
    required Dio dio,
  })  : _tokenService = tokenService,
        _dio = dio;

  final TokenService _tokenService;
  final Dio _dio;

  Dio get dio => _dio;

  Future<String?>? _ongoingRefresh;

  Future<String?> refreshToken() {
    if (_ongoingRefresh != null) {
      return _ongoingRefresh!;
    }
    _ongoingRefresh = _performRefresh().whenComplete(() {
      _ongoingRefresh = null;
    });
    return _ongoingRefresh!;
  }

  Future<String?> _performRefresh() async {
    final currentRefreshToken = await _tokenService.getRefreshToken();
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      await _tokenService.clearTokens();
      return null;
    }

    try {
      final response = await _dio.post(
        EndPoints.refresh,
        data: {'refreshToken': currentRefreshToken},
        options: Options(
          extra: {TokenInterceptor.skipAuthKey: true},
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _tokenService.saveAccessToken(newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _tokenService.saveRefreshToken(newRefreshToken);
          }
          return newAccessToken;
        }
      }

      await _tokenService.clearTokens();
      return null;
    } catch (_) {
      await _tokenService.clearTokens();
      return null;
    }
  }
}

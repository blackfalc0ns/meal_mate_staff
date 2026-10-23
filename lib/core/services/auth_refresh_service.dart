import 'dart:async';

import 'package:dio/dio.dart';

import '../network/network_constants.dart';
import 'token_service.dart';

class AuthRefreshService {
  AuthRefreshService({
    required this.tokenService,
    required this.dio,
    this.onTokensChanged,
    this.onSessionRejected,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final TokenService tokenService;
  // This client must not contain TokenInterceptor or a payload logger.
  final Dio dio;
  Future<void> Function(String access, String refresh)? onTokensChanged;
  Future<void> Function(String code)? onSessionRejected;
  void Function(String code)? onReauthenticate;
  final DateTime Function() _now;
  Future<String?>? _ongoingRefresh;
  DateTime? _retryAfter;
  String? terminalCode;

  Future<String?> ensureFreshToken() async {
    if (_ongoingRefresh != null) return _ongoingRefresh!;
    final token = await tokenService.getToken();
    if (token == null) return null;
    final expiry = await tokenService.getAccessTokenExpiry();
    if (expiry != null &&
        !expiry.isAfter(_now().toUtc().add(const Duration(minutes: 2)))) {
      final renewed = await refreshToken();
      if (renewed != null) return renewed;
      // A transient proactive failure must not suppress valid heartbeat requests.
      if (terminalCode == null && expiry.isAfter(_now().toUtc())) {
        return tokenService.getToken();
      }
      return null;
    }
    if (_ongoingRefresh != null) return _ongoingRefresh!;
    return token;
  }

  Future<String?> refreshToken({String? rejectedAccessToken}) async {
    if (_ongoingRefresh != null) return _ongoingRefresh!;
    final current = await tokenService.getToken();
    // A late 401 from a previous token must not rotate the new refresh token again.
    if (rejectedAccessToken != null &&
        current != null &&
        current != rejectedAccessToken) {
      return current;
    }
    if (_ongoingRefresh != null) return _ongoingRefresh!;
    if (_retryAfter != null && _now().isBefore(_retryAfter!)) return null;
    final operation = _performRefresh();
    _ongoingRefresh = operation;
    try {
      return await operation;
    } finally {
      _ongoingRefresh = null;
    }
  }

  Future<String?> _performRefresh() async {
    terminalCode = null;
    final generation = tokenService.sessionGeneration;
    final credential = await tokenService.getRefreshToken();
    if (credential == null || credential.isEmpty) {
      // No request can be made; an existing authenticated session has no renewal credential.
      if (await tokenService.getToken() != null) {
        await _reject('auth.invalid_refresh_token');
      }
      return null;
    }
    try {
      final response = await dio.post(
        EndPoints.refresh,
        data: {'refreshToken': credential},
        options: Options(
          extra: {'skipAuth': true},
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final data = response.data;
      if (data is! Map ||
          data['accessToken'] is! String ||
          data['refreshToken'] is! String ||
          (data['accessToken'] as String).isEmpty ||
          (data['refreshToken'] as String).isEmpty) {
        _retryAfter = _now().add(const Duration(seconds: 15));
        return null;
      }
      if (generation != tokenService.sessionGeneration) return null;
      final access = data['accessToken'] as String;
      final refresh = data['refreshToken'] as String;
      await tokenService.saveTokenPair(
        accessToken: access,
        refreshToken: refresh,
        accessTokenExpiresAtUtc: data['accessTokenExpiresAtUtc'] as String?,
        refreshTokenExpiresAtUtc: data['refreshTokenExpiresAtUtc'] as String?,
      );
      _retryAfter = null;
      await onTokensChanged?.call(access, refresh);
      return access;
    } on DioException catch (error) {
      if (generation != tokenService.sessionGeneration) return null;
      final data = error.response?.data;
      final code = data is Map
          ? (data['code'] ??
                (data['extensions'] is Map ? data['extensions']['code'] : null))
          : null;
      final status = error.response?.statusCode;
      if ((status == 401 && code == 'auth.invalid_refresh_token') ||
          (status == 403 &&
              const {
                'auth.account_suspended',
                'auth.account_closed',
                'family.password_setup_required',
              }.contains(code))) {
        await _reject(code as String);
      } else {
        _retryAfter = _now().add(const Duration(seconds: 15));
      }
      return null;
    } catch (_) {
      // Network, malformed responses and storage/bridge failures never imply revoked login.
      _retryAfter = _now().add(const Duration(seconds: 15));
      return null;
    }
  }

  Future<void> _reject(String code) async {
    terminalCode = code;
    // Stop local media before clearing credentials or navigating. No server close is required.
    try {
      await onSessionRejected?.call(code);
    } catch (_) {
      // A cleanup bridge failure cannot leave requests waiting or keep a revoked login usable.
    } finally {
      await tokenService.clearTokens();
      onReauthenticate?.call(code);
    }
  }
}

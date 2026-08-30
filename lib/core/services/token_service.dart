import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/keys.dart';
import '../utils/constants.dart';

class TokenService {
  TokenService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : this._(secureStorage, sharedPreferences);

  TokenService._(this._secureStorage, this._sharedPreferences);

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  bool get isAccessTokenSaved =>
      _sharedPreferences.getBool(CoreStorageKeys.isAccessTokenSaved) ?? false;

  Future<void> saveAccessToken(String token) async {
    await _sharedPreferences.setBool(CoreStorageKeys.isAccessTokenSaved, true);
    await _secureStorage.write(key: CoreStorageKeys.accessToken, value: token);
  }

  Future<String?> getToken() {
    if (!isAccessTokenSaved) return Future.value();
    return _secureStorage.read(key: CoreStorageKeys.accessToken);
  }

  Future<void> deleteToken() async {
    await _sharedPreferences.setBool(CoreStorageKeys.isAccessTokenSaved, false);
    await _secureStorage.delete(key: CoreStorageKeys.accessToken);
  }

  bool get isRefreshTokenSaved =>
      _sharedPreferences.getBool(CoreStorageKeys.isRefreshTokenSaved) ?? false;

  Future<void> saveRefreshToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await _sharedPreferences.setBool(CoreStorageKeys.isRefreshTokenSaved, true);
    await _secureStorage.write(key: CoreStorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() {
    if (!isRefreshTokenSaved) return Future.value();
    return _secureStorage.read(key: CoreStorageKeys.refreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _sharedPreferences.setBool(
      CoreStorageKeys.isRefreshTokenSaved,
      false,
    );
    await _secureStorage.delete(key: CoreStorageKeys.refreshToken);
  }

  Future<void> saveCurrentUserId(String userId) async {
    if (userId.trim().isEmpty) return;
    await _sharedPreferences.setString(CoreStorageKeys.userIdKey, userId);
  }

  String? getCurrentUserId() {
    final userId = _sharedPreferences.getString(CoreStorageKeys.userIdKey);
    return userId == null || userId.trim().isEmpty ? null : userId;
  }

  Future<void> clearTokens() async {
    await deleteToken();
    await deleteRefreshToken();
    await _sharedPreferences.remove(CoreStorageKeys.userIdKey);
    await _sharedPreferences.remove(StorageKeys.userData);
  }
}

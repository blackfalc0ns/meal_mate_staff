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

  static const String userRoleKey = 'userRoleKey';
  static const String userPhoneKey = 'userPhoneKey';
  static const String userNameKey = 'userNameKey';
  static const String userRestaurantIdKey = 'userRestaurantIdKey';
  static const String userAccountStatusKey = 'userAccountStatusKey';

  Future<void> saveCurrentUserId(String userId) async {
    if (userId.trim().isEmpty) return;
    await _sharedPreferences.setString(CoreStorageKeys.userIdKey, userId);
  }

  String? getCurrentUserId() {
    final userId = _sharedPreferences.getString(CoreStorageKeys.userIdKey);
    return userId == null || userId.trim().isEmpty ? null : userId;
  }

  String? getSavedRole() => _sharedPreferences.getString(userRoleKey);
  String? getSavedPhone() => _sharedPreferences.getString(userPhoneKey);
  String? getSavedFullName() => _sharedPreferences.getString(userNameKey);
  String? getSavedRestaurantId() =>
      _sharedPreferences.getString(userRestaurantIdKey);
  String? getSavedAccountStatus() =>
      _sharedPreferences.getString(userAccountStatusKey);

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    String? phone,
    String? fullName,
    String? restaurantId,
    String? accountStatus,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await saveCurrentUserId(userId);
    await _sharedPreferences.setString(userRoleKey, role);
    if (phone != null && phone.isNotEmpty) {
      await _sharedPreferences.setString(userPhoneKey, phone);
    }
    if (fullName != null && fullName.isNotEmpty) {
      await _sharedPreferences.setString(userNameKey, fullName);
    }
    if (restaurantId != null && restaurantId.isNotEmpty) {
      await _sharedPreferences.setString(userRestaurantIdKey, restaurantId);
    }
    if (accountStatus != null && accountStatus.isNotEmpty) {
      await _sharedPreferences.setString(userAccountStatusKey, accountStatus);
    }
  }

  Future<void> clearTokens() async {
    await deleteToken();
    await deleteRefreshToken();
    await _sharedPreferences.remove(CoreStorageKeys.userIdKey);
    await _sharedPreferences.remove(StorageKeys.userData);
    await _sharedPreferences.remove(userRoleKey);
    await _sharedPreferences.remove(userPhoneKey);
    await _sharedPreferences.remove(userNameKey);
    await _sharedPreferences.remove(userRestaurantIdKey);
    await _sharedPreferences.remove(userAccountStatusKey);
  }
}

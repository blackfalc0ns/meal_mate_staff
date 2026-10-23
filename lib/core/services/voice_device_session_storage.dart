import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class VoiceDeviceSessionStorage {
  VoiceDeviceSessionStorage({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String _prefDeviceSessionId = 'voice_v2_device_session_id';
  static const String _prefExpiresAtUtc = 'voice_v2_session_expires_at_utc';
  static const String _secureControlProof = 'voice_v2_control_proof';
  static const String _prefInstallationId = 'voice_v2_installation_id';
  static const String _prefFcmDeviceTokenId = 'voice_v2_fcm_device_token_id';

  Future<void> saveSession({
    required String deviceSessionId,
    required String controlProof,
    required String expiresAtUtc,
  }) async {
    await sharedPreferences.setString(_prefDeviceSessionId, deviceSessionId);
    await sharedPreferences.setString(_prefExpiresAtUtc, expiresAtUtc);
    await secureStorage.write(key: _secureControlProof, value: controlProof);
  }

  String? getDeviceSessionId() =>
      sharedPreferences.getString(_prefDeviceSessionId);

  DateTime? getExpiresAtUtc() {
    final str = sharedPreferences.getString(_prefExpiresAtUtc);
    if (str == null || str.isEmpty) return null;
    return DateTime.tryParse(str);
  }

  Future<String?> getControlProof() =>
      secureStorage.read(key: _secureControlProof);

  bool isSessionValid() {
    final sessionId = getDeviceSessionId();
    if (sessionId == null || sessionId.isEmpty) return false;
    final expires = getExpiresAtUtc();
    if (expires == null) return false;
    // Buffer of 60 seconds before actual expiration
    return DateTime.now().toUtc().isBefore(
          expires.subtract(const Duration(seconds: 60)),
        );
  }

  Future<void> clearSession() async {
    await sharedPreferences.remove(_prefDeviceSessionId);
    await sharedPreferences.remove(_prefExpiresAtUtc);
    await sharedPreferences.remove(_prefFcmDeviceTokenId);
    await secureStorage.delete(key: _secureControlProof);
  }

  String getOrCreateInstallationId(String fallback) {
    var id = sharedPreferences.getString(_prefInstallationId);
    if (id == null || id.isEmpty) {
      id = fallback;
      unawaited(sharedPreferences.setString(_prefInstallationId, id));
    }
    return id;
  }

  Future<void> saveFcmDeviceTokenId(String id) async {
    await sharedPreferences.setString(_prefFcmDeviceTokenId, id);
  }

  String? getFcmDeviceTokenId() =>
      sharedPreferences.getString(_prefFcmDeviceTokenId);
}

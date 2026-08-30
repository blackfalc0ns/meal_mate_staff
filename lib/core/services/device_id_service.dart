import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class DeviceIdService {
  DeviceIdService(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<String> getOrCreateDeviceId() async {
    final cachedId = _sharedPreferences.getString(CoreStorageKeys.deviceIdKey);
    if (cachedId != null && cachedId.isNotEmpty) return cachedId;

    final generatedId = _generateDeviceId();
    await _sharedPreferences.setString(
      CoreStorageKeys.deviceIdKey,
      generatedId,
    );
    return generatedId;
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final randomPart = List.generate(
      4,
      (_) => random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0'),
    ).join();
    return 'device-$timestamp-$randomPart';
  }
}

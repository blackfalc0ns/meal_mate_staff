import 'package:local_auth/local_auth.dart';

import 'biometric_auth_result.dart';

class BiometricService {
  BiometricService(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  Future<bool> get isAvailable async {
    return await _localAuthentication.canCheckBiometrics ||
        await _localAuthentication.isDeviceSupported();
  }

  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Please authenticate to continue',
  }) async {
    if (!await isAvailable) return BiometricAuthResult.unavailable;

    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(biometricOnly: false),
      );
      return authenticated
          ? BiometricAuthResult.authenticated
          : BiometricAuthResult.failed;
    } catch (_) {
      return BiometricAuthResult.failed;
    }
  }
}

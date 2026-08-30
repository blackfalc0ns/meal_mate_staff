import '../../../core/constants/assets.dart';
import '../domain/auth_verification_target.dart';

class AuthFakeData {
  const AuthFakeData._();

  static const phoneVerificationTarget = AuthVerificationTarget(
    value: '+966 50 123 4567',
    imageAsset: AssetsFake.authPhoneOtp,
  );

  static const emailVerificationTarget = AuthVerificationTarget(
    value: 'IbrahimYasser@gmail.com',
    imageAsset: AssetsFake.authEmailOtp,
  );
}

import '../user_role.dart';

class VerifyFirstTimeOtpResultEntity {
  const VerifyFirstTimeOtpResultEntity({
    required this.verified,
    required this.verificationToken,
    required this.phone,
    required this.role,
    this.message,
  });

  final bool verified;
  final String verificationToken;
  final String phone;
  final UserRole role;
  final String? message;
}

import '../user_role.dart';

class VerifyFirstTimeOtpRequestEntity {
  const VerifyFirstTimeOtpRequestEntity({
    required this.phone,
    required this.role,
    required this.otpCode,
  });

  final String phone;
  final UserRole role;
  final String otpCode;
}

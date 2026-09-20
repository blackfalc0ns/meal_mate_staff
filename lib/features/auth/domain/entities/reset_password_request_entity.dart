import '../user_role.dart';

class ResetPasswordRequestEntity {
  const ResetPasswordRequestEntity({
    required this.phone,
    required this.role,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String phone;
  final UserRole role;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;
}

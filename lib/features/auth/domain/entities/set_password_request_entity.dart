import '../user_role.dart';

class SetPasswordRequestEntity {
  const SetPasswordRequestEntity({
    required this.phone,
    required this.role,
    required this.verificationToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String phone;
  final UserRole role;
  final String verificationToken;
  final String newPassword;
  final String confirmPassword;
}

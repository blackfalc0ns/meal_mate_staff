import '../user_role.dart';

class ForgotPasswordRequestEntity {
  const ForgotPasswordRequestEntity({
    required this.phone,
    required this.role,
  });

  final String phone;
  final UserRole role;
}

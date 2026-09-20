import '../user_role.dart';

class StaffLoginRequestEntity {
  const StaffLoginRequestEntity({
    required this.phone,
    required this.role,
    required this.password,
  });

  final String phone;
  final UserRole role;
  final String password;
}

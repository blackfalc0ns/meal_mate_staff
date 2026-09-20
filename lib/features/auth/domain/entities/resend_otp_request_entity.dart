import '../user_role.dart';

class ResendOtpRequestEntity {
  const ResendOtpRequestEntity({required this.phone, required this.role});

  final String phone;
  final UserRole role;
}

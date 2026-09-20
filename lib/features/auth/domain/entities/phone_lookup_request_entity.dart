import '../user_role.dart';

class PhoneLookupRequestEntity {
  const PhoneLookupRequestEntity({required this.phone, required this.role});

  final String phone;
  final UserRole role;
}

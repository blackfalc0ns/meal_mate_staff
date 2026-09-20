import '../user_role.dart';

class AuthUserEntity {
  const AuthUserEntity({
    required this.userId,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
    this.restaurantId,
    this.accountStatus,
    this.roles = const [],
  });

  final String userId;
  final String phoneNumber;
  final String fullName;
  final UserRole role;
  final String? restaurantId;
  final String? accountStatus;
  final List<String> roles;
}

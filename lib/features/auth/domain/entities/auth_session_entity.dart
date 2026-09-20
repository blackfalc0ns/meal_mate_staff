import '../user_role.dart';
import 'auth_user_entity.dart';

class AuthSessionEntity {
  const AuthSessionEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAtUtc,
    this.isAuthenticated = true,
  });

  final AuthUserEntity user;
  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAtUtc;
  final bool isAuthenticated;

  UserRole get role => user.role;
  String get userId => user.userId;
  String get phoneNumber => user.phoneNumber;
  String get fullName => user.fullName;
}

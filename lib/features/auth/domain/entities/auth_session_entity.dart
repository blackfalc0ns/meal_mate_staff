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
}

import '../../domain/user_role.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AuthRoleChangedEvent extends AuthEvent {
  const AuthRoleChangedEvent(this.role);
  final UserRole role;
}

class AuthPhoneLookupEvent extends AuthEvent {
  const AuthPhoneLookupEvent({required this.phone, required this.role});

  final String phone;
  final UserRole role;
}

class AuthVerifyFirstTimeOtpEvent extends AuthEvent {
  const AuthVerifyFirstTimeOtpEvent({
    required this.phone,
    required this.role,
    required this.otpCode,
  });

  final String phone;
  final UserRole role;
  final String otpCode;
}

class AuthSetPasswordEvent extends AuthEvent {
  const AuthSetPasswordEvent({
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

class AuthLoginEvent extends AuthEvent {
  const AuthLoginEvent({
    required this.phone,
    required this.role,
    required this.password,
  });

  final String phone;
  final UserRole role;
  final String password;
}

class AuthForgotPasswordEvent extends AuthEvent {
  const AuthForgotPasswordEvent({required this.phone, required this.role});

  final String phone;
  final UserRole role;
}

class AuthResetPasswordEvent extends AuthEvent {
  const AuthResetPasswordEvent({
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

class AuthResendOtpEvent extends AuthEvent {
  const AuthResendOtpEvent({required this.phone, required this.role});

  final String phone;
  final UserRole role;
}

class AuthRestoreSessionEvent extends AuthEvent {
  const AuthRestoreSessionEvent();
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthClearFeedbackEvent extends AuthEvent {
  const AuthClearFeedbackEvent();
}

class AuthResetStateEvent extends AuthEvent {
  const AuthResetStateEvent();
}

class AuthGetStaffRolesEvent extends AuthEvent {
  const AuthGetStaffRolesEvent();
}


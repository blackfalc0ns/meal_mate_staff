import '../../../features/account_status/domain/account_status_kind.dart';
import '../../../features/auth/domain/auth_verification_target.dart';
import '../../../features/auth/domain/user_role.dart';

class LoginRouteArgs {
  const LoginRouteArgs({this.role = UserRole.operations});
  final UserRole role;
}

class OtpVerificationRouteArgs {
  const OtpVerificationRouteArgs({
    required this.target,
    this.role = UserRole.driver,
    this.verificationToken,
  });

  final AuthVerificationTarget target;
  final UserRole role;
  final String? verificationToken;
}

class AccountStatusRouteArgs {
  const AccountStatusRouteArgs({
    required this.kind,
    this.registrationId,
    this.phone,
    this.title,
    this.subtitle,
    this.canResubmit = false,
  });

  final AccountStatusKind kind;
  final String? registrationId;
  final String? phone;
  final String? title;
  final String? subtitle;
  final bool canResubmit;
}

class DriverRegistrationRouteArgs {
  const DriverRegistrationRouteArgs({
    this.role = UserRole.driver,
    this.phone,
    this.isResubmission = false,
    this.registrationId,
  });

  final UserRole role;
  final String? phone;
  final bool isResubmission;
  final String? registrationId;
}

class AppShellRouteArgs {
  const AppShellRouteArgs({
    this.role = UserRole.operations,
    this.initialIndex = 0,
  });

  final UserRole role;
  final int initialIndex;
}

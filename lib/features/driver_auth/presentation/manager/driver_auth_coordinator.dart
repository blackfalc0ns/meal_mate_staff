import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/auth/domain/auth_verification_target.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/driver_auth/domain/driver_auth_destination.dart';
import 'package:meal_mate_delivery/features/driver_auth/domain/resolve_driver_auth_destination.dart';

import '../../../../config/routing/arguments/auth_route_arguments.dart';

class DriverAuthCoordinator {
  const DriverAuthCoordinator();

  DriverAuthDestination resolve(PhoneLookupResultEntity lookup) {
    return resolveDriverAuthDestination(lookup);
  }

  void navigate(BuildContext context, DriverAuthDestination destination) {
    switch (destination) {
      case DriverRegistrationDestination(phone: final phone):
        context.pushNamed(
          AppRoutes.register,
          arguments: DriverRegistrationRouteArgs(
            phone: phone,
            role: UserRole.driver,
          ),
        );
      case DriverFirstTimeOtpDestination(phone: final phone):
        context.pushNamed(
          AppRoutes.verifyPhoneOtp,
          arguments: OtpVerificationRouteArgs(
            target: AuthVerificationTarget(
              value: phone,
              imageAsset: AppAssets.authPhoneOtp,
            ),
            role: UserRole.driver,
          ),
        );
      case DriverAccountStatusDestination(
          kind: final kind,
          registrationId: final registrationId,
          title: final title,
          subtitle: final subtitle,
          canResubmit: final canResubmit,
        ):
        context.pushNamed(
          AppRoutes.accountStatus,
          arguments: AccountStatusRouteArgs(
            kind: kind,
            registrationId: registrationId,
            title: title,
            subtitle: subtitle,
            canResubmit: canResubmit,
          ),
        );
      case DriverPasswordLoginDestination():
        context.pushNamed(
          AppRoutes.login,
          arguments: const LoginRouteArgs(role: UserRole.driver),
        );
      case DriverHomeDestination():
        context.pushReplacementNamed(
          AppRoutes.appShell,
          arguments: const AppShellRouteArgs(role: UserRole.driver),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/auth/domain/auth_verification_target.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/driver_auth/domain/driver_auth_destination.dart';
import 'package:meal_mate_delivery/features/driver_auth/domain/resolve_driver_auth_destination.dart';

class DriverAuthCoordinator {
  const DriverAuthCoordinator();

  DriverAuthDestination resolve(PhoneLookupResultEntity lookup) {
    return resolveDriverAuthDestination(lookup);
  }

  void navigate(BuildContext context, DriverAuthDestination destination) {
    switch (destination) {
      case DriverRegistrationDestination():
        context.pushNamed(
          AppRoutes.register,
          arguments: UserRole.driver,
        );
      case DriverFirstTimeOtpDestination(phone: final phone):
        context.pushNamed(
          AppRoutes.verifyPhoneOtp,
          arguments: AuthVerificationTarget(
            value: phone,
            imageAsset: AppAssets.authPhoneOtp,
          ),
        );
      case DriverAccountStatusDestination(kind: final kind):
        context.pushNamed(
          AppRoutes.accountStatus,
          arguments: kind,
        );
      case DriverPasswordLoginDestination():
        // Stay on login screen to enter password
        break;
      case DriverHomeDestination():
        context.pushReplacementNamed(
          AppRoutes.appShell,
          arguments: UserRole.driver,
        );
    }
  }
}

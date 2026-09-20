import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/core/widget/custom_snak_bar.dart';
import 'package:meal_mate_delivery/features/auth/domain/auth_verification_target.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/dispatcher_auth/domain/dispatcher_auth_destination.dart';
import 'package:meal_mate_delivery/features/dispatcher_auth/domain/resolve_dispatcher_auth_destination.dart';

class DispatcherAuthCoordinator {
  const DispatcherAuthCoordinator();

  DispatcherAuthDestination resolve(PhoneLookupResultEntity lookup) {
    return resolveDispatcherAuthDestination(lookup);
  }

  void navigate(BuildContext context, DispatcherAuthDestination destination) {
    switch (destination) {
      case DispatcherAccountNotFoundDestination():
        CustomSnackbar.showError(
          context: context,
          message:
              'هذا الرقم غير مسجل كمسؤول توصيل. يرجى التواصل مع إدارة المطعم لإضافتك أولاً.',
        );
      case DispatcherFirstTimeOtpDestination(phone: final phone):
        context.pushNamed(
          AppRoutes.verifyPhoneOtp,
          arguments: AuthVerificationTarget(
            value: phone,
            imageAsset: AppAssets.authPhoneOtp,
          ),
        );
      case DispatcherPasswordLoginDestination():
        // Stay on login screen to enter password
        break;
      case DispatcherHomeDestination():
        context.pushReplacementNamed(
          AppRoutes.appShell,
          arguments: UserRole.operations,
        );
    }
  }
}

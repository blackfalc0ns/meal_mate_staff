import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/services/token_service.dart';
import '../../../../auth/domain/usecase/logout_usecase.dart';
import '../../../../auth/domain/user_role.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/fake_data/driver_profile_fake_data.dart';
import '../widgets/driver_profile_contact_card.dart';
import '../widgets/driver_profile_header.dart';
import '../widgets/driver_profile_hero_card.dart';
import '../widgets/driver_profile_policy_banner.dart';
import '../widgets/driver_profile_quick_actions_row.dart';
import '../widgets/driver_profile_ticket_card.dart';
import '../widgets/driver_profile_vehicle_card.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({
    super.key,
    this.profile,
    this.onNotificationTap,
    this.onVehicleInfoTap,
    this.onContactUsTap,
    this.onViewAllTicketsTap,
    this.onRecentTicketTap,
    this.onLanguageTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  final DriverProfileEntity? profile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onVehicleInfoTap;
  final VoidCallback? onContactUsTap;
  final VoidCallback? onViewAllTicketsTap;
  final VoidCallback? onRecentTicketTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  void _handleSettingsTap(BuildContext context) {
    if (onSettingsTap != null) {
      onSettingsTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSettings));
  }

  void _handleNotificationTap(BuildContext context) {
    if (onNotificationTap != null) {
      onNotificationTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverNotifications));
  }

  void _handleVehicleInfoTap(BuildContext context) {
    if (onVehicleInfoTap != null) {
      onVehicleInfoTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverVehicleDetails));
  }

  void _handleContactUsTap(BuildContext context) {
    if (onContactUsTap != null) {
      onContactUsTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSupport));
  }

  void _handleViewAllTicketsTap(BuildContext context) {
    if (onViewAllTicketsTap != null) {
      onViewAllTicketsTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSupportTickets));
  }

  void _handleRecentTicketTap(BuildContext context) {
    if (onRecentTicketTap != null) {
      onRecentTicketTap!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSupportTickets));
  }

  void _handleLogout(BuildContext context) {
    if (onLogoutTap != null) {
      onLogoutTap!();
      return;
    }

    final locale = context.localization;
    final color = context.colorScheme;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
        return AlertDialog(
          title: Text(locale.driverLogoutConfirmTitle),
          content: Text(locale.driverLogoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(locale.profileCancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (getIt.isRegistered<LogoutUseCase>()) {
                  await getIt<LogoutUseCase>()();
                } else if (getIt.isRegistered<TokenService>()) {
                  await getIt<TokenService>().clearTokens();
                }
                if (!context.mounted) return;
                context.pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                  arguments: const LoginRouteArgs(role: UserRole.driver),
                );
              },
              child: Text(
                locale.driverQuickActionLogout,
                style: TextStyle(color: color.error),
              ),
            ),
          ],
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final currentProfile = profile ?? DriverProfileFakeData.defaultProfile;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverProfileHeader(
        onNotificationTap: () => _handleNotificationTap(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenH,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverProfileHeroCard(profile: currentProfile),
              const SizedBox(height: Spacing.md),
              DriverProfileVehicleCard(
                 profile: currentProfile,
                onTap: () => _handleVehicleInfoTap(context),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    size: 20,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.driverSupportSectionTitle,
                    style: getBoldStyle(
                      fontSize: FontSize.size13,
                      color: color.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs + 2),
              DriverProfileContactCard(
                onTap: () => _handleContactUsTap(context),
              ),
              const SizedBox(height: Spacing.md),
              DriverProfileTicketCard(
                profile: currentProfile,
                onTap: () => _handleRecentTicketTap(context),
                onViewAllTap: () => _handleViewAllTicketsTap(context),
              ),
              const SizedBox(height: Spacing.md),
              DriverProfileQuickActionsRow(
                onLanguageTap: onLanguageTap,
                onSettingsTap: () => _handleSettingsTap(context),
                onLogoutTap: () => _handleLogout(context),
              ),
              const SizedBox(height: Spacing.md),
              const DriverProfilePolicyBanner(),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),

    );
  }
}


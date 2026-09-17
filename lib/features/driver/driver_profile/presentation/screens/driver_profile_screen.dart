import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/fake_data/driver_profile_fake_data.dart';
import '../widgets/driver_profile_delivery_policy_banner.dart';
import '../widgets/driver_profile_header.dart';
import '../widgets/driver_profile_info_card.dart';
import '../widgets/driver_profile_quick_action_tile.dart';
import '../widgets/driver_profile_recent_ticket_card.dart';
import '../widgets/driver_profile_support_card.dart';
import '../widgets/driver_profile_vehicle_card.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({
    super.key,
    this.profile,
    this.onNotificationTap,
    this.onContactSupportTap,
    this.onViewAllTicketsTap,
    this.onLanguageTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  final DriverProfileEntity? profile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onContactSupportTap;
  final VoidCallback? onViewAllTicketsTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  void _handleLogout(BuildContext context) {
    if (onLogoutTap != null) {
      onLogoutTap!();
      return;
    }

    final locale = context.localization;
    final color = context.colorScheme;

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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
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
    );
  }

  void _handleNotificationTap(BuildContext context) {
    if (onNotificationTap != null) {
      onNotificationTap!();
      return;
    }
    context.pushNamed(AppRoutes.driverNotifications);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final currentProfile = profile ?? DriverProfileFakeData.defaultProfile;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverProfileHeader(
                onNotificationTap: () => _handleNotificationTap(context),
              ),
              const SizedBox(height: Spacing.base),
              DriverProfileInfoCard(profile: currentProfile),
              const SizedBox(height: Spacing.base),
              DriverProfileVehicleCard(profile: currentProfile),
              const SizedBox(height: Spacing.base),
              DriverProfileSupportCard(
                onTap: onContactSupportTap,
              ),
              const SizedBox(height: Spacing.base),
              DriverProfileRecentTicketCard(
                profile: currentProfile,
                onViewAllTap: onViewAllTicketsTap,
              ),
              const SizedBox(height: Spacing.base),
              DriverProfileQuickActionTile(
                icon: Icons.language_rounded,
                title: locale.driverQuickActionLanguage,
                subtitle: locale.driverQuickActionLanguageValue,
                onTap: onLanguageTap,
              ),
              const SizedBox(height: Spacing.sm),
              DriverProfileQuickActionTile(
                icon: Icons.tune_rounded,
                title: locale.driverQuickActionSettings,
                subtitle: locale.driverQuickActionSettingsDesc,
                onTap: onSettingsTap,
              ),
              const SizedBox(height: Spacing.sm),
              DriverProfileQuickActionTile(
                icon: Icons.logout_rounded,
                title: locale.driverQuickActionLogout,
                subtitle: locale.driverQuickActionLogoutDesc,
                isDestructive: true,
                onTap: () => _handleLogout(context),
              ),
              const SizedBox(height: Spacing.base),
              const DriverProfileDeliveryPolicyBanner(),
              const SizedBox(height: Spacing.bottomNavHeight + Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

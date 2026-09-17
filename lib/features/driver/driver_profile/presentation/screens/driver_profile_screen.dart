import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/fake_data/driver_profile_fake_data.dart';
import '../widgets/driver_settings_header.dart';
import '../widgets/driver_settings_logout_button.dart';
import '../widgets/driver_settings_menu_tile.dart';
import '../widgets/driver_settings_profile_card.dart';
import '../widgets/driver_settings_section_card.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({
    super.key,
    this.profile,
    this.onNotificationTap,
    this.onMenuTap,
    this.onEditProfileTap,
    this.onPersonalInfoTap,
    this.onVehicleInfoTap,
    this.onMyDocumentsTap,
    this.onChangePasswordTap,
    this.onLanguageTap,
    this.onNotificationsTap,
    this.onSoundsTap,
    this.onHelpCenterTap,
    this.onContactUsTap,
    this.onAboutAppTap,
    this.onPrivacyPolicyTap,
    this.onLogoutTap,
  });

  final DriverProfileEntity? profile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onEditProfileTap;
  final VoidCallback? onPersonalInfoTap;
  final VoidCallback? onVehicleInfoTap;
  final VoidCallback? onMyDocumentsTap;
  final VoidCallback? onChangePasswordTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSoundsTap;
  final VoidCallback? onHelpCenterTap;
  final VoidCallback? onContactUsTap;
  final VoidCallback? onAboutAppTap;
  final VoidCallback? onPrivacyPolicyTap;
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
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
              child: Text(
                locale.driverSettingsLogout,
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

  void _handleVehicleInfoTap(BuildContext context) {
    if (onVehicleInfoTap != null) {
      onVehicleInfoTap!();
      return;
    }
    context.pushNamed(AppRoutes.driverVehicleDetails);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final currentProfile = profile ?? DriverProfileFakeData.defaultProfile;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverSettingsHeader(
        onNotificationTap: () => _handleNotificationTap(context),
        onMenuTap: onMenuTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverSettingsProfileCard(
                profile: currentProfile,
                onEditProfileTap: onEditProfileTap,
              ),
              const SizedBox(height: Spacing.base),
              // Section 1: Account Settings
              DriverSettingsSectionCard(
                title: locale.driverSettingsAccountSection,
                icon: Icons.person_outline_rounded,
                children: [
                  DriverSettingsMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: locale.driverSettingsPersonalInfo,
                    onTap: onPersonalInfoTap,
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.directions_car_outlined,
                    title: locale.driverSettingsVehicleInfo,
                    onTap: () => _handleVehicleInfoTap(context),
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.description_outlined,
                    title: locale.driverSettingsMyDocuments,
                    onTap: onMyDocumentsTap,
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: locale.driverSettingsChangePassword,
                    onTap: onChangePasswordTap,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.base),
              // Section 2: App Settings
              DriverSettingsSectionCard(
                title: locale.driverSettingsAppSection,
                icon: Icons.settings_outlined,
                children: [
                  DriverSettingsMenuTile(
                    icon: Icons.language_rounded,
                    title: locale.driverSettingsLanguage,
                    trailingText: locale.driverSettingsLanguageValue,
                    onTap: onLanguageTap,
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: locale.driverSettingsNotifications,
                    onTap:
                        onNotificationsTap ??
                        () => _handleNotificationTap(context),
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.volume_up_outlined,
                    title: locale.driverSettingsSounds,
                    onTap: onSoundsTap,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.base),
              // Section 3: Support & Help
              DriverSettingsSectionCard(
                title: locale.driverSettingsSupportSection,
                icon: Icons.headset_mic_outlined,
                children: [
                  DriverSettingsMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: locale.driverSettingsHelpCenter,
                    onTap: onHelpCenterTap,
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.support_agent_rounded,
                    title: locale.driverSettingsContactUs,
                    onTap: onContactUsTap,
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: locale.driverSettingsAboutApp,
                    onTap: onAboutAppTap,
                  ),
                  DriverSettingsMenuTile(
                    icon: Icons.verified_user_outlined,
                    title: locale.driverSettingsPrivacyPolicy,
                    onTap: onPrivacyPolicyTap,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              DriverSettingsLogoutButton(
                onLogoutTap: () => _handleLogout(context),
                version: locale.driverSettingsAppVersion,
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

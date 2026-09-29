import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import 'driver_profile_quick_action_item.dart';

class DriverProfileQuickActionsRow extends StatelessWidget {
  const DriverProfileQuickActionsRow({
    super.key,
    this.onLanguageTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  final VoidCallback? onLanguageTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return Row(
      children: [
        Expanded(
          child: DriverProfileQuickActionItem(
            icon: Icons.language_rounded,
            title: locale.driverQuickActionLanguage,
            subtitle: locale.driverQuickActionLanguageValue,
            onTap: onLanguageTap,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: DriverProfileQuickActionItem(
            icon: Icons.settings_outlined,
            title: locale.driverQuickActionSettings,
            subtitle: locale.driverQuickActionSettingsDesc,
            onTap: onSettingsTap,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: DriverProfileQuickActionItem(
            icon: Icons.logout_rounded,
            title: locale.driverQuickActionLogout,
            subtitle: locale.driverQuickActionLogoutDesc,
            onTap: onLogoutTap,
          ),
        ),
      ],
    );
  }
}

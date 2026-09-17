import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/widget/app_button.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSettingsLogoutButton extends StatelessWidget {
  const DriverSettingsLogoutButton({
    super.key,
    required this.onLogoutTap,
    this.version,
  });

  final VoidCallback onLogoutTap;
  final String? version;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          height: Spacing.buttonSmallHeight,
          text: locale.driverSettingsLogout,
          icon: Icons.logout_rounded,
          onPressed: onLogoutTap,
          iconSize: Spacing.iconMd,
          color: color.error.withValues(alpha: 0.08),
          textColor: color.error,
          textStyle: getBoldStyle(
            color: color.error,
            fontSize: FontSize.size12,
          ),
          borderRadius: Spacing.cardRadius,
        ),
        const SizedBox(height: Spacing.md),
        Text(
          version ?? locale.driverSettingsAppVersion,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

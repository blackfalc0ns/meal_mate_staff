import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';

class DriverSettingsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverSettingsHeader({
    super.key,
    this.onNotificationTap,
    this.onMenuTap,
    this.showBackButton,
    this.onBackPressed,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(106.0);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final canPop = Navigator.canPop(context);
    final shouldShowBack = showBackButton ?? canPop;

    return CustomAppBar.logo(
      leading: shouldShowBack
          ? null
          : (onMenuTap != null
              ? IconButton(
                  icon: Icon(Icons.menu, color: color.onSurface, size: Spacing.iconMd),
                  onPressed: onMenuTap,
                )
              : null),
      showBackButton: shouldShowBack,
      onBackPressed: onBackPressed,
      actions: [
        NotificationButton(onPressed: onNotificationTap),
        const SizedBox(width: Spacing.xs),
      ],
      title: locale.driverSettingsTitle,
      subtitle: locale.driverSettingsSubtitle,
    );
  }
}

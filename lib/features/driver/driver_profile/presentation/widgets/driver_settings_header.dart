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
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(106.0);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return CustomAppBar.logo(
      leading: IconButton(
        icon: Icon(Icons.menu, color: color.onSurface, size: Spacing.iconMd),
        onPressed: onMenuTap,
      ),
      actions: [
        NotificationButton(onPressed: onNotificationTap),
        const SizedBox(width: Spacing.xs),
      ],
      title: locale.driverSettingsTitle,
      subtitle: locale.driverSettingsSubtitle,
    );
  }
}

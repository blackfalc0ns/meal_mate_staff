import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';

class DriverSupportHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverSupportHeader({
    super.key,
    this.onBack,
    this.onNotificationTap,
    this.onMenuTap,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(106.0);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final canPop = Navigator.of(context).canPop();

    return CustomAppBar.logo(
      leading: (canPop || onBack != null)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: Icon(
                Icons.menu,
                color: color.onSurface,
                size: Spacing.iconMd,
              ),
              onPressed: onMenuTap,
            ),
      actions: [
        NotificationButton(onPressed: onNotificationTap),
        const SizedBox(width: Spacing.xs),
      ],
      title: locale.driverSupportTitle,
      subtitle: locale.driverSupportSubtitle,
    );
  }
}

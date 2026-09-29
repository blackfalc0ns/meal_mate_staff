import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';

class DriverProfileHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverProfileHeader({
    super.key,
    this.onNotificationTap,
  });

  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(106.0);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar.logo(
      showBackButton: false,
      actions: [
        NotificationButton(onPressed: onNotificationTap),
        const SizedBox(width: Spacing.xs),
      ],
      title: locale.driverProfileTitle,
      subtitle: locale.driverProfileSubtitle,
    );
  }
}

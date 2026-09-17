import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../../orders/presentation/widgets/driver_boxes_header_logo.dart';

class DriverSettingsHeader extends StatelessWidget {
  const DriverSettingsHeader({
    super.key,
    this.onNotificationTap,
    this.onMenuTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NotificationButton(
              onPressed: onNotificationTap,
            ),
            const DriverBoxesHeaderLogo(),
            IconButton(
              icon: Icon(
                Icons.menu,
                color: color.onSurface,
                size: Spacing.iconMd,
              ),
              onPressed: onMenuTap,
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          locale.driverSettingsTitle,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size22,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.driverSettingsSubtitle,
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

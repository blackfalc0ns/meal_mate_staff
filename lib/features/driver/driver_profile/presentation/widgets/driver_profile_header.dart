import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../../orders/presentation/widgets/driver_boxes_header_logo.dart';

class DriverProfileHeader extends StatelessWidget {
  const DriverProfileHeader({
    super.key,
    this.onNotificationTap,
  });

  final VoidCallback? onNotificationTap;

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
            const SizedBox(width: Spacing.iconLg + Spacing.sm),
            const DriverBoxesHeaderLogo(),
            NotificationButton(
              onPressed: onNotificationTap,
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          locale.driverProfileTitle,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.driverProfileSubtitle,
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

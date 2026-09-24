import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverTrackingTitleSection extends StatelessWidget {
  const DriverTrackingTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          locale.driverActiveTrackingReadyTitle,
          style: getSemiBoldStyle(
            fontSize: FontSize.size16,
            color: color.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.driverActiveTrackingEnRouteSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

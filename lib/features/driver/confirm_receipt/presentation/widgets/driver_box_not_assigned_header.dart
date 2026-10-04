import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxNotAssignedHeader extends StatelessWidget {
  const DriverBoxNotAssignedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          locale.driverBoxNotAssignedTitle,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          locale.driverBoxNotAssignedSubtitle,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size12,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

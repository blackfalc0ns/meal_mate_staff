import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxReceivedSuccessHeader extends StatelessWidget {
  const DriverBoxReceivedSuccessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          locale.driverBoxReceivedSuccessTitle,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          locale.driverBoxReceivedSuccessSubtitle,
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

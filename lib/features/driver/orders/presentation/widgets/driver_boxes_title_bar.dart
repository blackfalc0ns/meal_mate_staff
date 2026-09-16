import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import 'driver_boxes_delivery_mode_chip.dart';

class DriverBoxesTitleBar extends StatelessWidget {
  const DriverBoxesTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locale.driverBoxesTitle,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size18,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                locale.driverBoxesSubtitle,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.sm),
        const DriverBoxesDeliveryModeChip(),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverReceivedBoxesHeaderBar extends StatelessWidget {
  const DriverReceivedBoxesHeaderBar({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: Spacing.iconSm,
              color: color.primary,
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              locale.driverReceivedBoxesTitle,
              style: getBoldStyle(
                color: color.onSurface,
                fontSize: FontSize.size14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
          ),
          child: Text(
            locale.driverBoxesCountBadge,
            style: getMediumStyle(
              color: color.primary,
              fontSize: FontSize.size11,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class AssignBoxDriversHeader extends StatelessWidget {
  const AssignBoxDriversHeader({super.key, this.onViewAllPressed});

  final VoidCallback? onViewAllPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            locale.assignBoxSelectDriver,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size14,
            ),
          ),
        ),
        InkWell(
          onTap: onViewAllPressed,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.assignBoxViewAll,
                  style: getMediumStyle(
                    color: color.primary,
                    fontSize: FontSize.size12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

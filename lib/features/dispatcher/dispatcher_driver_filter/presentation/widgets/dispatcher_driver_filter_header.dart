import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DispatcherDriverFilterHeader extends StatelessWidget {
  const DispatcherDriverFilterHeader({super.key, this.onClose, this.onReset});

  final VoidCallback? onClose;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Close Button
        InkWell(
          onTap: onClose ?? () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(
                color: color.outlineVariant,
                width: Spacing.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.close_rounded,
                  size: Spacing.iconMd,
                  color: color.onSurface,
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  locale.driverFilterClose,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size10,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Title and Subtitle Center
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locale.driverFilterTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs / 2),
              Text(
                locale.driverFilterSubtitle,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Reset Button
        InkWell(
          onTap: onReset,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(
                color: color.outlineVariant,
                width: Spacing.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restart_alt_rounded,
                  size: Spacing.iconMd,
                  color: color.onSurface,
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  locale.driverFilterReset,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size10,
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

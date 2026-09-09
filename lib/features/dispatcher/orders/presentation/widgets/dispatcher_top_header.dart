import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherTopHeader extends StatelessWidget {
  const DispatcherTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: Spacing.iconSm + Spacing.xs,
                  color: color.onSurface,
                ),
                const SizedBox(width: Spacing.xs),
                Flexible(
                  child: Text(
                    locale.dispatcherRestaurantName,
                    style: getSemiBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: Spacing.iconSm, color: color.primary),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.dispatcherRoleBadge,
                  style: getSemiBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/return_box_entity.dart';

class ReturnBoxStatusCard extends StatelessWidget {
  const ReturnBoxStatusCard({super.key, required this.returnBox});

  final ReturnBoxEntity returnBox;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                returnBox.boxCode,
                style: getBoldStyle(
                  fontSize: FontSize.size16,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.secondaryContainer,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Text(
                    locale.driverBoxStatusReturning,
                    style: getSemiBoldStyle(
                      fontSize: FontSize.size11,
                      color: color.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          const Divider(height: Spacing.md),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: Spacing.iconSm + 2,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  returnBox.restaurantName,
                  style: getBoldStyle(
                    fontSize: FontSize.size14,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: Spacing.iconSm,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  returnBox.restaurantAddress,
                  style: getRegularStyle(
                    fontSize: FontSize.size12,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: color.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  size: Spacing.iconSm,
                  color: color.error,
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    returnBox.failureReason,
                    style: getMediumStyle(
                      fontSize: FontSize.size12,
                      color: color.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

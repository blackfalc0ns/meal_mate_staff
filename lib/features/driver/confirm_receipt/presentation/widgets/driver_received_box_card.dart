import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_received_box_item_entity.dart';

class DriverReceivedBoxCard extends StatelessWidget {
  const DriverReceivedBoxCard({
    super.key,
    required this.item,
  });

  final DriverReceivedBoxItemEntity item;

  static const double _numberBoxSize = 32;
  static const double _badgeIconSize = 13;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outline,
          width: Spacing.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _numberBoxSize,
            height: _numberBoxSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(
                color: color.outline,
                width: Spacing.hairline,
              ),
            ),
            child: Text(
              '${item.indexNumber}',
              style: getBoldStyle(
                color: color.onSurface,
                fontSize: FontSize.size12,
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.boxCode,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size14,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${locale.driverBoxConditionLabel} ',
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size11,
                        ),
                      ),
                      TextSpan(
                        text: locale.driverBoxConditionValue,
                        style: getMediumStyle(
                          color: color.tertiary,
                          fontSize: FontSize.size11,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.tertiaryContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: _badgeIconSize,
                  color: color.tertiary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driverBoxStatusReceived,
                  style: getMediumStyle(
                    color: color.tertiary,
                    fontSize: FontSize.size11,
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

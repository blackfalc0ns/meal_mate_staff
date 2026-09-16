import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverStep2PreviewCard extends StatelessWidget {
  const DriverStep2PreviewCard({
    super.key,
    required this.isUnlocked,
  });

  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: isUnlocked
            ? color.primaryContainer.withValues(alpha: 0.3)
            : color.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: isUnlocked
              ? color.primary.withValues(alpha: 0.5)
              : color.outlineVariant.withValues(alpha: 0.4),
          width: Spacing.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? color.primary
                  : color.primary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              color: color.onPrimary,
              size: Spacing.iconMd,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.driverPhotographBoxTitle,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size14,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color.outlineVariant.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: getBoldStyle(
                            color: color.onSurfaceVariant,
                            fontSize: FontSize.size10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.hairline * 4),
                Text(
                  isUnlocked
                      ? locale.driverPhotographBoxSubtitle
                      : locale.driverStep2ActivatedAfterScan,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

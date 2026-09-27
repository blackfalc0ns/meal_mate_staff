import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherProfileDriversStatusCard extends StatelessWidget {
  const DispatcherProfileDriversStatusCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.sports_motorsports_rounded,
                    size: Spacing.iconMd,
                    color: color.primary,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.driversStatusTitle,
                        style: getBoldStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size14,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.driversStatusSubtitle,
                        style: getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size12,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: Spacing.iconSm,
                  color: color.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

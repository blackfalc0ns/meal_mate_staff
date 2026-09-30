import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class CustomerCallInfoCard extends StatelessWidget {
  const CustomerCallInfoCard({
    super.key,
    required this.customerName,
    required this.customerPhone,
    required this.isPhoneUnlocked,
  });

  final String customerName;
  final String customerPhone;
  final bool isPhoneUnlocked;

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
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: Spacing.base,
            backgroundColor: color.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_rounded,
              size: Spacing.iconMd,
              color: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customerName,
                  style: getBoldStyle(
                    fontSize: FontSize.size14,
                    color: color.onSurface,
                  ),
                ),
                if (isPhoneUnlocked) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    customerPhone,
                    textDirection: TextDirection.ltr,
                    style: getRegularStyle(
                      fontSize: FontSize.size12,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: isPhoneUnlocked
                  ? color.secondaryContainer.withValues(alpha: 0.3)
                  : color.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPhoneUnlocked
                      ? Icons.check_circle_outline_rounded
                      : Icons.lock_outline_rounded,
                  size: Spacing.iconXs,
                  color: isPhoneUnlocked ? color.secondary : color.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  isPhoneUnlocked
                      ? locale.driverCallExternalAvailable
                      : locale.driverCallProtectedNumber,
                  style: getMediumStyle(
                    fontSize: FontSize.size10,
                    color: isPhoneUnlocked ? color.secondary : color.primary,
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

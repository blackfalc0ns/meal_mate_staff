import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformanceHeader extends StatelessWidget {
  const DriverPerformanceHeader({
    super.key,
    required this.formattedDate,
    required this.isOnline,
    this.showBackButton = true,
    this.onBackTap,
  });

  final String formattedDate;
  final bool isOnline;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.driverPerformanceTitle,
              style: getBoldStyle(
                fontSize: FontSize.size20,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: color.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  formattedDate,
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (isOnline)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: color.tertiaryContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusXl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driverPerformanceOnlineStatus,
                  style: getMediumStyle(
                    fontSize: FontSize.size11,
                    color: color.tertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

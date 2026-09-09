import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_order_priority.dart';

class DispatcherPriorityBadge extends StatelessWidget {
  const DispatcherPriorityBadge({super.key, required this.priority});

  final DispatcherOrderPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final String text;
    final Color textColor;
    final Color surfaceColor;
    final IconData? icon;

    switch (priority) {
      case DispatcherOrderPriority.newOrder:
        text = locale.dispatcherPriorityNew;
        textColor = color.dispatcherBadgeNew;
        surfaceColor = color.dispatcherBadgeNewSurface;
        icon = null;
      case DispatcherOrderPriority.urgent:
        text = locale.dispatcherPriorityUrgent;
        textColor = color.dispatcherBadgeUrgent;
        surfaceColor = color.dispatcherBadgeUrgentSurface;
        icon = Icons.campaign_rounded;
      case DispatcherOrderPriority.highPriority:
        text = locale.dispatcherPriorityHigh;
        textColor = color.dispatcherBadgeHigh;
        surfaceColor = color.dispatcherBadgeHighSurface;
        icon = Icons.star_rounded;
      case DispatcherOrderPriority.normal:
        text = locale.dispatcherPriorityNormal;
        textColor = color.dispatcherBadgeNormal;
        surfaceColor = color.dispatcherBadgeNormalSurface;
        icon = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: Spacing.iconSm - Spacing.xs / 2, color: textColor),
            const SizedBox(width: Spacing.xs / 2),
          ],
          Text(
            text,
            style: getSemiBoldStyle(
              color: textColor,
              fontSize: FontSize.size10,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_metric_entity.dart';
import '../../domain/entities/dispatcher_metric_type.dart';

class DispatcherMetricCard extends StatelessWidget {
  const DispatcherMetricCard({super.key, required this.metric});

  final DispatcherMetricEntity metric;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final String label;
    final IconData icon;
    final Color iconColor;

    switch (metric.type) {
      case DispatcherMetricType.pendingAssignment:
        label = locale.dispatcherStatusPendingAssignment;
        icon = Icons.access_time_rounded;
        iconColor = color.secondary;
      case DispatcherMetricType.assigned:
        label = locale.dispatcherStatusAssigned;
        icon = Icons.check_circle_outline_rounded;
        iconColor = color.tertiary;
      case DispatcherMetricType.inDelivery:
        label = locale.dispatcherStatusInDelivery;
        icon = Icons.two_wheeler_rounded;
        iconColor = color.info;
      case DispatcherMetricType.problems:
        label = locale.dispatcherStatusProblems;
        icon = Icons.alarm_rounded;
        iconColor = color.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: color.outline, width: Spacing.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: getMediumStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Icon(icon, size: Spacing.iconSm, color: iconColor),

              //   const SizedBox(width: Spacing.xs),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            '${metric.count}',
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size20,
            ),
          ),
        ],
      ),
    );
  }
}

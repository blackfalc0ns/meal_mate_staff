import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import 'dispatcher_drivers_avatar_with_status.dart';
import 'dispatcher_drivers_card_metrics_row.dart';
import 'dispatcher_drivers_card_top_row.dart';

class DispatcherDriversCard extends StatelessWidget {
  const DispatcherDriversCard({
    super.key,
    required this.driver,
    this.onSelect,
  });

  final DispatcherDriverEntity driver;
  final ValueChanged<DispatcherDriverEntity>? onSelect;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DispatcherDriversAvatarWithStatus(
            status: driver.status,
            avatarUrl: driver.avatarUrl,
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            width: Spacing.border,
            height: Spacing.dispatcherCardDividerHeight,
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DispatcherDriversCardTopRow(
                  driver: driver,
                  onSelect: onSelect,
                ),
                const SizedBox(height: Spacing.sm),
                DispatcherDriversCardMetricsRow(driver: driver),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

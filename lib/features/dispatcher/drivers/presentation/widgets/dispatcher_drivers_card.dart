import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
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
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: Spacing.hairline + Spacing.border / 10),
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: Spacing.hairline / 10),
            blurRadius: Spacing.xs,
            offset: const Offset(Spacing.zero, Spacing.border),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DispatcherDriversCardTopRow(
            driver: driver,
            onSelect: onSelect,
          ),
          const SizedBox(height: Spacing.xs),
          Divider(
            height: Spacing.border,
            color: color.outlineVariant.withValues(alpha: Spacing.hairline - Spacing.border / 10),
          ),
          const SizedBox(height: Spacing.xs),
          DispatcherDriversCardMetricsRow(driver: driver),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_map_kpi_entity.dart';
import 'dispatcher_map_kpi_card.dart';

class DispatcherMapKpiBar extends StatelessWidget {
  const DispatcherMapKpiBar({
    super.key,
    required this.kpi,
  });

  final DispatcherMapKpiEntity kpi;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          Expanded(
            child: DispatcherMapKpiCard(
              icon: Icons.inventory_2_rounded,
              iconColor: color.success,
              iconBgColor: color.success.withValues(alpha: 0.15),
              count: kpi.activeDriversCount,
              label: locale.mapKpiActive,
              statusColor: color.success,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: DispatcherMapKpiCard(
              icon: Icons.local_shipping_rounded,
              iconColor: color.primary,
              iconBgColor: color.primary.withValues(alpha: 0.15),
              count: kpi.inDeliveryCount,
              label: locale.mapKpiInDelivery,
              statusColor: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: DispatcherMapKpiCard(
              icon: Icons.access_time_filled_rounded,
              iconColor: color.info,
              iconBgColor: color.info.withValues(alpha: 0.15),
              count: kpi.pausedCount,
              label: locale.mapKpiPaused,
              statusColor: color.info,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: DispatcherMapKpiCard(
              icon: Icons.info_rounded,
              iconColor: color.error,
              iconBgColor: color.error.withValues(alpha: 0.15),
              count: kpi.issuesCount,
              label: locale.mapKpiIssues,
              statusColor: color.error,
            ),
          ),
        ],
      ),
    );
  }
}

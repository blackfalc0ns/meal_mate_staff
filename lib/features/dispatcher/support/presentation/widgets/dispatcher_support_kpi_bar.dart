import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_support_kpi_entity.dart';
import 'dispatcher_support_area_card.dart';
import 'dispatcher_support_kpi_card.dart';

class DispatcherSupportKpiBar extends StatelessWidget {
  const DispatcherSupportKpiBar({
    super.key,
    required this.kpi,
    this.onAreaTap,
  });

  final DispatcherSupportKpiEntity kpi;
  final VoidCallback? onAreaTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: DispatcherSupportAreaCard(
              area: kpi.currentArea,
              onTap: onAreaTap,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            flex: 7,
            child: DispatcherSupportKpiCard(
              title: locale.supportMissingIssues,
              count: kpi.missingCount,
              icon: Icons.info_rounded,
              statusColor: color.error,
              backgroundColor: color.errorContainer,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            flex: 7,
            child: DispatcherSupportKpiCard(
              title: locale.supportResolvingIssues,
              count: kpi.inProgressCount,
              icon: Icons.access_time_filled_rounded,
              statusColor: color.secondary,
              backgroundColor: color.secondaryContainer,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            flex: 7,
            child: DispatcherSupportKpiCard(
              title: locale.supportResolvedIssues,
              count: kpi.resolvedCount,
              icon: Icons.check_circle_rounded,
              statusColor: color.tertiary,
              backgroundColor: color.tertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

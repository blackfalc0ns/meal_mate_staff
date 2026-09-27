import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import 'dispatcher_drivers_status_kpi_item.dart';

class DispatcherDriversStatusKpiSection extends StatelessWidget {
  const DispatcherDriversStatusKpiSection({
    super.key,
    required this.kpis,
    this.onSelectFilter,
    this.selectedFilter,
  });

  final DispatcherDriversStatusKpisEntity kpis;
  final ValueChanged<DispatcherDriverStatusType?>? onSelectFilter;
  final DispatcherDriverStatusType? selectedFilter;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          // 1. Total KPI
          DispatcherDriversStatusKpiItem(
            title: locale.driversStatusTotalCount,
            count: kpis.total,
            icon: Icon(
              Icons.people_outline_rounded,
              size: Spacing.iconXs,
              color: color.primary,
            ),
            iconColor: color.primary,
            backgroundColor: selectedFilter == null
                ? color.primary.withValues(alpha: 0.12)
                : color.surfaceContainerHighest.withValues(alpha: 0.3),
            onTap: () => onSelectFilter?.call(null),
          ),
          const SizedBox(width: Spacing.xs),
          // 2. Available KPI
          DispatcherDriversStatusKpiItem(
            title: locale.driversStatusAvailableCount,
            count: kpis.available,
            icon: Container(
              width: Spacing.xs + Spacing.border,
              height: Spacing.xs + Spacing.border,
              decoration: BoxDecoration(
                color: color.success,
                shape: BoxShape.circle,
              ),
            ),
            iconColor: color.success,
            backgroundColor:
                selectedFilter == DispatcherDriverStatusType.available
                ? color.success.withValues(alpha: 0.15)
                : color.successSurface,
            onTap: () =>
                onSelectFilter?.call(DispatcherDriverStatusType.available),
          ),
          const SizedBox(width: Spacing.xs),
          // 3. In Delivery KPI
          DispatcherDriversStatusKpiItem(
            title: locale.driversStatusInDeliveryCount,
            count: kpis.inDelivery,
            icon: Icon(
              Icons.access_time_rounded,
              size: Spacing.iconXs,
              color: color.info,
            ),
            iconColor: color.info,
            backgroundColor:
                selectedFilter == DispatcherDriverStatusType.inDelivery
                ? color.info.withValues(alpha: 0.15)
                : color.infoSurface,
            onTap: () =>
                onSelectFilter?.call(DispatcherDriverStatusType.inDelivery),
          ),
          const SizedBox(width: Spacing.xs),
          // 4. Unavailable KPI
          DispatcherDriversStatusKpiItem(
            title: locale.driversStatusUnavailableCount,
            count: kpis.unavailable,
            icon: Icon(
              Icons.notifications_active_outlined,
              size: Spacing.iconXs,
              color: color.error,
            ),
            iconColor: color.error,
            backgroundColor:
                selectedFilter == DispatcherDriverStatusType.unavailable
                ? color.error.withValues(alpha: 0.15)
                : color.errorSurface,
            onTap: () =>
                onSelectFilter?.call(DispatcherDriverStatusType.unavailable),
          ),
        ],
      ),
    );
  }
}

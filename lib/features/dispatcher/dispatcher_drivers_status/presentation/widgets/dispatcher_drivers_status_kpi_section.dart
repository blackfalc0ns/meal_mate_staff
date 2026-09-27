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
  });

  final DispatcherDriversStatusKpisEntity kpis;
  final ValueChanged<DispatcherDriverStatusType?>? onSelectFilter;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          DispatcherDriversStatusKpiItem(
            title: locale.driversStatusOfflineCount,
            count: kpis.offlineCount,
            icon: Icon(
              Icons.notifications_active_outlined,
              size: Spacing.iconXs,
              color: color.error,
            ),
            iconColor: color.error,
            backgroundColor: color.errorSurface,
            onTap: () => onSelectFilter?.call(DispatcherDriverStatusType.offline),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherDriversStatusKpiItem(
            title: locale.driversStatusInDeliveryCount,
            count: kpis.inDeliveryCount,
            icon: Icon(
              Icons.access_time_rounded,
              size: Spacing.iconXs,
              color: color.info,
            ),
            iconColor: color.info,
            backgroundColor: color.infoSurface,
            onTap: () => onSelectFilter?.call(DispatcherDriverStatusType.available),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherDriversStatusKpiItem(
            title: locale.driversStatusConnectedCount,
            count: kpis.connectedCount,
            icon: Container(
              width: Spacing.sm,
              height: Spacing.sm,
              decoration: BoxDecoration(
                color: color.success,
                shape: BoxShape.circle,
              ),
            ),
            iconColor: color.success,
            backgroundColor: color.successSurface,
            onTap: () => onSelectFilter?.call(DispatcherDriverStatusType.connected),
          ),
        ],
      ),
    );
  }
}

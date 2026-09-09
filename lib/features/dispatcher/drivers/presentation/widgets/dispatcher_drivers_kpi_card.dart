import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_drivers_kpi_entity.dart';
import 'dispatcher_drivers_kpi_segment.dart';
import 'dispatcher_drivers_vertical_divider.dart';

class DispatcherDriversKpiCard extends StatelessWidget {
  const DispatcherDriversKpiCard({super.key, required this.kpi});

  final DispatcherDriversKpiEntity kpi;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: Spacing.hairline),
          ),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: Spacing.hairline / 10),
              blurRadius: Spacing.sm - Spacing.border - Spacing.border,
              offset: const Offset(Spacing.zero, Spacing.border + Spacing.border),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: DispatcherDriversKpiSegment(
                value: kpi.totalDrivers.toString(),
                label: locale.driversTotalCount,
                icon: Icons.people_alt_rounded,
                iconColor: color.primary,
                iconBgColor: color.primaryContainer,
              ),
            ),
            const DispatcherDriversVerticalDivider(),
            Expanded(
              child: DispatcherDriversKpiSegment(
                value: kpi.availableDrivers.toString(),
                label: locale.driversAvailableCount,
                icon: Icons.person_rounded,
                iconColor: color.tertiary,
                iconBgColor: color.tertiaryContainer,
              ),
            ),
            const DispatcherDriversVerticalDivider(),
            Expanded(
              child: DispatcherDriversKpiSegment(
                value: kpi.busyNow.toString(),
                label: locale.driversBusyCount,
                icon: Icons.person_rounded,
                iconColor: color.secondary,
                iconBgColor: color.secondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

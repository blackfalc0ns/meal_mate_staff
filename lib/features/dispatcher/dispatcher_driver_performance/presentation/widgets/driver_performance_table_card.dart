import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_record_entity.dart';
import 'driver_performance_driver_row.dart';
import 'driver_performance_table_header.dart';

class DriverPerformanceTableCard extends StatelessWidget {
  const DriverPerformanceTableCard({
    super.key,
    required this.drivers,
    this.onSelectDriver,
  });

  final List<DriverPerformanceRecordEntity> drivers;
  final ValueChanged<DriverPerformanceRecordEntity>? onSelectDriver;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text(
              locale.driverPerformanceDriversSection,
              style: getBoldStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          const DriverPerformanceTableHeader(),
          Divider(
            color: color.outlineVariant.withValues(alpha: 0.4),
            height: Spacing.sm,
            thickness: Spacing.border,
          ),
          ...drivers.map(
            (record) => DriverPerformanceDriverRow(
              record: record,
              onTap: onSelectDriver != null
                  ? () => onSelectDriver!(record)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

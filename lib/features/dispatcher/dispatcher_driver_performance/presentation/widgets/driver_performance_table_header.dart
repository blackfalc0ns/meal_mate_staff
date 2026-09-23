import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_sort_field.dart';

class DriverPerformanceTableHeader extends StatelessWidget {
  const DriverPerformanceTableHeader({
    super.key,
    this.sortField,
    this.sortAscending = false,
    this.onSort,
  });

  final DriverPerformanceSortField? sortField;
  final bool sortAscending;
  final ValueChanged<DriverPerformanceSortField>? onSort;

  Widget _buildColumnHeader({
    required BuildContext context,
    required String label,
    required DriverPerformanceSortField field,
    required int flex,
    TextAlign textAlign = TextAlign.center,
  }) {
    final color = context.colorScheme;
    final isSelected = sortField == field;

    final headerStyle = getMediumStyle(
      fontFamily: FontConstant.alexandria,
      fontSize: FontSize.size10,
      color: isSelected ? color.primary : color.onSurfaceVariant,
    );

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onSort != null ? () => onSort!(field) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: textAlign == TextAlign.start
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: headerStyle,
                textAlign: textAlign,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 2),
              Icon(
                sortAscending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 10,
                color: color.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          _buildColumnHeader(
            context: context,
            label: locale.driverPerformanceColDriver,
            field: DriverPerformanceSortField.driver,
            flex: 3,
            textAlign: TextAlign.start,
          ),
          _buildColumnHeader(
            context: context,
            label: locale.driverPerformanceColDelivered,
            field: DriverPerformanceSortField.delivered,
            flex: 2,
          ),
          _buildColumnHeader(
            context: context,
            label: locale.driverPerformanceColAvgDelay,
            field: DriverPerformanceSortField.avgDelay,
            flex: 2,
          ),
          _buildColumnHeader(
            context: context,
            label: locale.driverPerformanceColDeliveryFailed,
            field: DriverPerformanceSortField.failedDelivery,
            flex: 2,
          ),
          _buildColumnHeader(
            context: context,
            label: locale.driverPerformanceColRating,
            field: DriverPerformanceSortField.rating,
            flex: 2,
          ),
        ],
      ),
    );
  }
}

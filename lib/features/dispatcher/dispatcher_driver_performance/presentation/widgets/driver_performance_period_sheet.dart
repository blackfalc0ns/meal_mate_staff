import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_period.dart';

class DriverPerformancePeriodSheet extends StatelessWidget {
  const DriverPerformancePeriodSheet({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    required this.onCustomRangeSelected,
    this.initialCustomFrom,
    this.initialCustomTo,
  });

  final DriverPerformancePeriod selectedPeriod;
  final ValueChanged<DriverPerformancePeriod> onPeriodSelected;
  final void Function(DateTime fromDate, DateTime toDate) onCustomRangeSelected;
  final DateTime? initialCustomFrom;
  final DateTime? initialCustomTo;

  static Future<void> show(
    BuildContext context, {
    required DriverPerformancePeriod selectedPeriod,
    required ValueChanged<DriverPerformancePeriod> onPeriodSelected,
    required void Function(DateTime fromDate, DateTime toDate)
    onCustomRangeSelected,
    DateTime? initialCustomFrom,
    DateTime? initialCustomTo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusLg),
        ),
      ),
      builder: (_) => DriverPerformancePeriodSheet(
        selectedPeriod: selectedPeriod,
        onPeriodSelected: onPeriodSelected,
        onCustomRangeSelected: onCustomRangeSelected,
        initialCustomFrom: initialCustomFrom,
        initialCustomTo: initialCustomTo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final presets = [
      (DriverPerformancePeriod.today, locale.driverPerformanceToday),
      (DriverPerformancePeriod.yesterday, locale.driverPerformanceYesterday),
      (DriverPerformancePeriod.last7Days, locale.driverPerformanceLast7Days),
      (DriverPerformancePeriod.last30Days, locale.driverPerformanceLast30Days),
      (DriverPerformancePeriod.thisMonth, locale.driverPerformanceThisMonth),
      (DriverPerformancePeriod.custom, locale.driverPerformanceCustom),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: color.outlineVariant,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Title
            Text(
              locale.driverPerformancePeriodSheetTitle,
              style: getBoldStyle(
                fontSize: FontSize.size16,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.md),

            // List of presets
            ...presets.map((item) {
              final preset = item.$1;
              final label = item.$2;
              final isSelected = preset == selectedPeriod;

              return ListTile(
                title: Text(
                  label,
                  style: isSelected
                      ? getBoldStyle(
                          fontSize: FontSize.size14,
                          color: color.primary,
                        )
                      : getRegularStyle(
                          fontSize: FontSize.size14,
                          color: color.onSurface,
                        ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: color.primary)
                    : null,
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  if (preset == DriverPerformancePeriod.custom) {
                    Navigator.of(context).pop();
                    await _selectCustomDateRange(context);
                  } else {
                    onPeriodSelected(preset);
                    Navigator.of(context).pop();
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2);
    final lastDate = DateTime(now.year + 1);

    final initialRange = DateTimeRange(
      start: initialCustomFrom ?? now.subtract(const Duration(days: 7)),
      end: initialCustomTo ?? now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialRange,
    );

    if (picked != null) {
      final start = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      final end = DateTime(picked.end.year, picked.end.month, picked.end.day);
      onCustomRangeSelected(start, end);
    }
  }
}

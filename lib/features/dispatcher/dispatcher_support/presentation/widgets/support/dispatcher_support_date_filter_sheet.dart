import 'package:flutter/material.dart';
import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_support_date_preset.dart';

class DispatcherSupportDateFilterSheet extends StatelessWidget {
  const DispatcherSupportDateFilterSheet({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.onCustomRangeSelected,
    this.initialCustomFrom,
    this.initialCustomTo,
  });

  final DispatcherSupportDatePreset selectedPreset;
  final ValueChanged<DispatcherSupportDatePreset> onPresetSelected;
  final void Function(DateTime fromUtc, DateTime toUtc) onCustomRangeSelected;
  final DateTime? initialCustomFrom;
  final DateTime? initialCustomTo;

  static Future<void> show(
    BuildContext context, {
    required DispatcherSupportDatePreset selectedPreset,
    required ValueChanged<DispatcherSupportDatePreset> onPresetSelected,
    required void Function(DateTime fromUtc, DateTime toUtc)
    onCustomRangeSelected,
    DateTime? initialCustomFrom,
    DateTime? initialCustomTo,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusLg),
        ),
      ),
      builder: (_) => DispatcherSupportDateFilterSheet(
        selectedPreset: selectedPreset,
        onPresetSelected: onPresetSelected,
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
      (DispatcherSupportDatePreset.today, locale.supportDatePresetToday),
      (
        DispatcherSupportDatePreset.yesterday,
        locale.supportDatePresetYesterday,
      ),
      (
        DispatcherSupportDatePreset.last7Days,
        locale.supportDatePresetLast7Days,
      ),
      (
        DispatcherSupportDatePreset.last30Days,
        locale.supportDatePresetLast30Days,
      ),
      (DispatcherSupportDatePreset.custom, locale.supportDatePresetCustom),
    ];

    return SafeArea(
      child: Padding(
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
              locale.supportDateFilterTitle,
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
              final isSelected = preset == selectedPreset;

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
                  if (preset == DispatcherSupportDatePreset.custom) {
                    Navigator.of(context).pop();
                    await _selectCustomDateRange(context);
                  } else {
                    onPresetSelected(preset);
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
    final firstDate = DateTime(now.year - 1);
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
      final startUtc = DateTime.utc(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      final endUtc = DateTime.utc(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );
      onCustomRangeSelected(startUtc, endUtc);
    }
  }
}

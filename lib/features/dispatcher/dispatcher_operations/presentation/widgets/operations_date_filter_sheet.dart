import 'package:flutter/material.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/operations_date_preset.dart';

class OperationsDateFilterSheet extends StatelessWidget {
  const OperationsDateFilterSheet({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.onCustomRangeSelected,
    this.initialCustomFrom,
    this.initialCustomTo,
  });

  final OperationsDatePreset selectedPreset;
  final ValueChanged<OperationsDatePreset> onPresetSelected;
  final void Function(DateTime fromUtc, DateTime toUtc) onCustomRangeSelected;
  final DateTime? initialCustomFrom;
  final DateTime? initialCustomTo;

  static Future<void> show(
    BuildContext context, {
    required OperationsDatePreset selectedPreset,
    required DateTime? initialCustomFrom,
    required DateTime? initialCustomTo,
    required ValueChanged<OperationsDatePreset> onPresetSelected,
    required void Function(DateTime fromUtc, DateTime toUtc)
    onCustomRangeSelected,
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
      builder: (_) => OperationsDateFilterSheet(
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final presets = [
      (OperationsDatePreset.today, locale.supportDatePresetToday),
      (OperationsDatePreset.last7Days, locale.operationsLast7Days),
      (
        OperationsDatePreset.last30Days,
        isArabic ? 'آخر 30 يوماً' : locale.supportDatePresetLast30Days,
      ),
      (OperationsDatePreset.all, locale.operationsTabAll),
      (OperationsDatePreset.custom, locale.supportDatePresetCustom),
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
            Text(
              locale.supportDateFilterTitle,
              style: getBoldStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size16,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.md),
            ...presets.map((item) {
              final preset = item.$1;
              final label = item.$2;
              final isSelected = preset == selectedPreset;

              return ListTile(
                title: Text(
                  label,
                  style: isSelected
                      ? getBoldStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size14,
                          color: color.primary,
                        )
                      : getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size14,
                          color: color.onSurface,
                        ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: color.primary)
                    : null,
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  if (preset == OperationsDatePreset.custom) {
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
    final firstDate = DateTime(now.year - 2);
    final lastDate = DateTime(now.year + 1);

    final initialRange = DateTimeRange(
      start:
          initialCustomFrom?.toLocal() ?? now.subtract(const Duration(days: 7)),
      end: initialCustomTo?.toLocal() ?? now,
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

      if (!startUtc.isAfter(endUtc)) {
        onCustomRangeSelected(startUtc, endUtc);
      }
    }
  }
}

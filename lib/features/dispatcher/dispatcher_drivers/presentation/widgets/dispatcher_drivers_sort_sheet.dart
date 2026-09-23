import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_sort.dart';

class DispatcherDriversSortSheet extends StatelessWidget {
  const DispatcherDriversSortSheet({
    super.key,
    required this.selectedSort,
    required this.onSortSelected,
  });

  final DispatcherDriverSort selectedSort;
  final ValueChanged<DispatcherDriverSort> onSortSelected;

  static Future<DispatcherDriverSort?> show(
    BuildContext context, {
    required DispatcherDriverSort currentSort,
  }) {
    return showModalBottomSheet<DispatcherDriverSort>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusXl),
        ),
      ),
      builder: (context) => DispatcherDriversSortSheet(
        selectedSort: currentSort,
        onSortSelected: (sort) => Navigator.of(context).pop(sort),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final options = [
      (
        DispatcherDriverSort.nearestDistance,
        isArabic ? 'الأقرب مسافة' : 'Nearest Distance',
        Icons.near_me_rounded,
      ),
      (
        DispatcherDriverSort.highestRating,
        isArabic ? 'الأعلى تقييماً' : 'Highest Rating',
        Icons.star_rounded,
      ),
      (
        DispatcherDriverSort.leastActiveLoad,
        isArabic ? 'الأقل حمولة نشطة' : 'Least Active Load',
        Icons.inventory_2_rounded,
      ),
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
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: color.outlineVariant,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: Spacing.base),
            Text(
              isArabic ? 'ترتيب السائقين حسب' : 'Sort Drivers By',
              style: getBoldStyle(
                fontSize: FontSize.size16,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            ...options.map((opt) {
              final sort = opt.$1;
              final label = opt.$2;
              final icon = opt.$3;
              final isSelected = sort == selectedSort;

              return ListTile(
                leading: Icon(
                  icon,
                  color: isSelected ? color.primary : color.onSurfaceVariant,
                ),
                title: Text(
                  label,
                  style: isSelected
                      ? getSemiBoldStyle(
                          fontSize: FontSize.size14,
                          color: color.primary,
                        )
                      : getRegularStyle(
                          fontSize: FontSize.size14,
                          color: color.onSurface,
                        ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: color.primary)
                    : null,
                contentPadding: EdgeInsets.zero,
                onTap: () => onSortSelected(sort),
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_drivers_status_sort.dart';

class DispatcherDriversStatusSortButton extends StatelessWidget {
  const DispatcherDriversStatusSortButton({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  final DispatcherDriversStatusSort currentSort;
  final ValueChanged<DispatcherDriversStatusSort> onSortSelected;

  String _getSortLabel(BuildContext context, DispatcherDriversStatusSort sort) {
    final locale = context.localization;
    return switch (sort) {
      DispatcherDriversStatusSort.name => locale.driversStatusSortName,
      DispatcherDriversStatusSort.ratingDesc =>
        locale.driversStatusSortRatingDesc,
      DispatcherDriversStatusSort.newest => locale.driversStatusSortNewest,
      DispatcherDriversStatusSort.status => locale.driversStatusSortStatus,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return PopupMenuButton<DispatcherDriversStatusSort>(
      key: const Key('dispatcher_drivers_status_sort_button'),
      initialValue: currentSort,
      onSelected: onSortSelected,
      tooltip: context.localization.driversStatusSortTitle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      itemBuilder: (context) => DispatcherDriversStatusSort.values.map((sort) {
        return PopupMenuItem<DispatcherDriversStatusSort>(
          value: sort,
          child: Text(
            _getSortLabel(context, sort),
            style: sort == currentSort
                ? getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size11,
                    color: color.primary,
                  )
                : getRegularStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size11,
                    color: color.onSurface,
                  ),
          ),
        );
      }).toList(),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.6),
            width: Spacing.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_vert_rounded,
              size: Spacing.iconSm,
              color: color.primary,
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              _getSortLabel(context, currentSort),
              style: getMediumStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size11,
                color: color.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

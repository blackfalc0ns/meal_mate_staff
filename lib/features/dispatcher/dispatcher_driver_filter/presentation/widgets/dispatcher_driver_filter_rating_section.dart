import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'dispatcher_driver_filter_card_frame.dart';

class DispatcherDriverFilterRatingSection extends StatelessWidget {
  const DispatcherDriverFilterRatingSection({
    super.key,
    required this.minRating,
    required this.onRatingSelected,
  });

  final double? minRating;
  final ValueChanged<double?> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final ratings = [
      (key: null, label: locale.driverFilterAllRatings),
      (key: 4.5, label: locale.driverFilterRating4Point5Plus),
      (key: 4.0, label: locale.driverFilterRating4Plus),
      (key: 3.0, label: locale.driverFilterRating3Plus),
      (key: 2.0, label: locale.driverFilterRating2Plus),
      (key: 1.0, label: locale.driverFilterRating1Plus),
    ];

    return DispatcherDriverFilterCardFrame(
      title: locale.driverFilterByRating,
      icon: Icon(
        Icons.star_rounded,
        size: Spacing.iconSm,
        color: color.primary,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ratings.map((rating) {
            final isSelected = minRating == rating.key;

            final borderColor = color.outline.withValues(alpha: 0.5);

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: Spacing.xs + 2),
              child: InkWell(
                onTap: () => onRatingSelected(rating.key),
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color.primary : color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    border: isSelected
                        ? null
                        : Border.all(color: borderColor, width: Spacing.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rating.key != null) ...[
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: isSelected ? color.onPrimary : color.secondary,
                        ),
                        const SizedBox(width: Spacing.xs),
                      ],
                      Text(
                        rating.label,
                        style: isSelected
                            ? getBoldStyle(
                                color: color.onPrimary,
                                fontSize: FontSize.size11,
                              )
                            : getRegularStyle(
                                color: color.onSurfaceVariant,
                                fontSize: FontSize.size11,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

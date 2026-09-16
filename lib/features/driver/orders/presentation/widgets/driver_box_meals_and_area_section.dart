import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxMealsAndAreaSection extends StatelessWidget {
  const DriverBoxMealsAndAreaSection({
    super.key,
    required this.mealCount,
    required this.area,
  });

  final int mealCount;
  final String area;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$mealCount ${locale.driverMealsUnit}',
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          locale.driverMealCountLabel,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: Spacing.iconXs,
              color: color.primary,
            ),

            const SizedBox(width: Spacing.xs),

            Flexible(
              child: Text(
                area,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Text(
          locale.driverAreaLabel,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

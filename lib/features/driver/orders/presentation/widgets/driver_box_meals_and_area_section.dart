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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$mealCount ${locale.driverMealsUnit}',
          style: getSemiBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          locale.driverMealCountLabel,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size8,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.hairline * 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: Spacing.iconXs - 3,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.hairline * 2),
            Flexible(
              child: Text(
                area,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

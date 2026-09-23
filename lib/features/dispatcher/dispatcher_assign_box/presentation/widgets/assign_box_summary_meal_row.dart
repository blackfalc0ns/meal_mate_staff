import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_meal_entity.dart';

class AssignBoxSummaryMealRow extends StatelessWidget {
  const AssignBoxSummaryMealRow({super.key, required this.meal});

  final AssignBoxMealEntity meal;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Text(
              '${meal.quantity}x',
              style: getBoldStyle(
                color: color.primary,
                fontSize: FontSize.size12,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),

          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealName,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size13,
                  ),
                ),
                if (meal.category != null && meal.category!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs / 2),
                  Text(
                    meal.category!,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size11,
                    ),
                  ),
                ],
                if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: Spacing.iconXs,
                        color: color.error,
                      ),
                      const SizedBox(width: Spacing.xs / 2),
                      Expanded(
                        child: Text(
                          meal.notes!,
                          style: getRegularStyle(
                            color: color.error,
                            fontSize: FontSize.size11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

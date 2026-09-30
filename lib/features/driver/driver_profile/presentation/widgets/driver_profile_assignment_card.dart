import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_assignment_entity.dart';

class DriverProfileAssignmentCard extends StatelessWidget {
  const DriverProfileAssignmentCard({
    super.key,
    required this.assignment,
  });

  final DriverProfileAssignmentEntity? assignment;

  @override
  Widget build(BuildContext context) {
    if (assignment == null) return const SizedBox.shrink();

    final restaurant = assignment!.restaurantName?.trim();
    final branch = assignment!.branchName?.trim();

    final hasRestaurant = restaurant != null && restaurant.isNotEmpty;
    final hasBranch = branch != null && branch.isNotEmpty;

    if (!hasRestaurant && !hasBranch) {
      return const SizedBox.shrink();
    }

    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 20,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  locale.driverAssignmentTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              if (hasRestaurant)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.driverAssignmentRestaurant,
                        style: getRegularStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        restaurant,
                        style: getBoldStyle(
                          fontSize: FontSize.size11,
                          color: color.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasRestaurant && hasBranch) const SizedBox(width: Spacing.md),
              if (hasBranch)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.driverAssignmentBranch,
                        style: getRegularStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        branch,
                        style: getBoldStyle(
                          fontSize: FontSize.size11,
                          color: color.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

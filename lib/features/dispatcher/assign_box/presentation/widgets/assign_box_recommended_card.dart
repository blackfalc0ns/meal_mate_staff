import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_candidate_driver_entity.dart';
import 'assign_box_driver_avatar.dart';
import 'assign_box_driver_metric_chip.dart';
import 'assign_box_driver_status_badge.dart';
import 'assign_box_driver_tag_badge.dart';

class AssignBoxRecommendedCard extends StatelessWidget {
  const AssignBoxRecommendedCard({
    super.key,
    required this.driver,
    required this.isSelected,
    required this.onSelected,
  });

  final AssignBoxCandidateDriverEntity driver;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.primary,
            width: Spacing.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.dispatcherSuggestionSurface,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    border: Border.all(color: color.primaryBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: Spacing.iconSm,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        locale.assignBoxBestSuggestion,
                        style: getSemiBoldStyle(
                          color: color.primary,
                          fontSize: FontSize.size11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? color.primary : color.outlineVariant,
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                AssignBoxDriverAvatar(
                  badgeNumber: driver.badgeNumber,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        driver.name,
                        style: getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size14,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      AssignBoxDriverStatusBadge(
                        statusType: driver.statusType,
                        statusText: driver.statusText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.xs,
              children: [
                AssignBoxDriverTagBadge(
                  tagText: driver.tagText,
                  isPrimary: true,
                ),
                if (driver.currentLoadText != null)
                  AssignBoxDriverMetricChip(
                    icon: Icons.inventory_2_outlined,
                    text:
                        '${locale.assignBoxCurrentLoad}: ${driver.currentLoadText}',
                  ),
                AssignBoxDriverMetricChip(
                  icon: Icons.near_me_outlined,
                  text: '${locale.assignBoxDistanceLabel}: ${driver.distanceText}',
                ),
                if (driver.expectedCompletionText != null)
                  AssignBoxDriverMetricChip(
                    icon: Icons.access_time_rounded,
                    text:
                        '${locale.assignBoxExpectedCompletion}: ${driver.expectedCompletionText}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

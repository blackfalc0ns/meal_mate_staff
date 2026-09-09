import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_candidate_driver_entity.dart';
import 'assign_box_driver_avatar.dart';
import 'assign_box_driver_metric_chip.dart';
import 'assign_box_driver_status_badge.dart';
import 'assign_box_driver_tag_badge.dart';

class AssignBoxDriverCard extends StatelessWidget {
  const AssignBoxDriverCard({
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
            color: isSelected ? color.primary : color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? color.primary : color.outlineVariant,
                ),
                const SizedBox(width: Spacing.md),
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
                          fontSize: FontSize.size13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Wrap(
                        spacing: Spacing.xs,
                        runSpacing: Spacing.xs,
                        children: [
                          AssignBoxDriverStatusBadge(
                            statusType: driver.statusType,
                            statusText: driver.statusText,
                          ),
                          AssignBoxDriverTagBadge(
                            tagText: driver.tagText,
                            isPrimary: driver.tagText == 'الأقل ضغطاً',
                          ),
                        ],
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
                AssignBoxDriverMetricChip(
                  icon: Icons.near_me_outlined,
                  text: '${locale.assignBoxDistanceLabel}: ${driver.distanceText}',
                ),
                if (driver.currentLoadText != null)
                  AssignBoxDriverMetricChip(
                    icon: Icons.inventory_2_outlined,
                    text:
                        '${locale.assignBoxCurrentLoad}: ${driver.currentLoadText}',
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

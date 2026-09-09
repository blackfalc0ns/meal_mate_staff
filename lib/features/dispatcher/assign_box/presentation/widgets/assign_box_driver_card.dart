import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_candidate_driver_entity.dart';
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
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: isSelected ? color.primary : color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Badge number + Radio Button column (Far right in RTL)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (driver.badgeNumber != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: Spacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.dispatcherSuggestionSurface,
                      borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    ),
                    child: Text(
                      driver.badgeNumber!,
                      style: getBoldStyle(
                        color: color.primary,
                        fontSize: FontSize.size9,
                      ),
                    ),
                  ),
                const SizedBox(height: Spacing.xs / 2),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? color.primary : color.outlineVariant,
                  size: Spacing.iconSm + 2,
                ),
              ],
            ),
            const SizedBox(width: Spacing.xs),
            // 2. Avatar with purple border
            Container(
              width: Spacing.registrationStepCircle,
              height: Spacing.registrationStepCircle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.surface,
                border: Border.all(color: color.primary, width: Spacing.border),
              ),
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: Spacing.iconSm,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            // 3. Driver Info: Status Badge, Name, Tag Badge
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 82),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AssignBoxDriverStatusBadge(
                    statusType: driver.statusType,
                    statusText: driver.statusText,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    driver.name,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.xs),
                  AssignBoxDriverTagBadge(tagText: driver.tagText),
                ],
              ),
            ),
            const SizedBox(width: Spacing.xs),
            // 4. The 3 Metrics: Distance, Current Load, Expected Completion
            Expanded(
              child: Row(
                children: [
                  // Distance Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: Spacing.md,
                              color: color.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xs / 2),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  locale.assignBoxDistanceLabel,
                                  style: getMediumStyle(
                                    color: color.onSurfaceVariant,
                                    fontSize: FontSize.size9,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs / 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            driver.distanceText,
                            style: getSemiBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size11,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs / 2),
                  // Current Load Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: Spacing.md,
                              color: color.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xs / 2),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  locale.assignBoxCurrentLoad,
                                  style: getRegularStyle(
                                    color: color.onSurfaceVariant,
                                    fontSize: FontSize.size9,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs / 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            driver.currentLoadText ?? '0 بوكسات',
                            style: getSemiBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size11,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  // Expected Completion Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: Spacing.md,
                              color: color.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  locale.assignBoxExpectedCompletion,
                                  style: getRegularStyle(
                                    color: color.onSurfaceVariant,
                                    fontSize: FontSize.size9,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            driver.expectedCompletionText ?? '10:20 ص',
                            style: getSemiBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size11,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_candidate_driver_entity.dart';

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
      borderRadius: BorderRadius.circular(Spacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          border: Border.all(color: color.primary, width: Spacing.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Badge (Align top-right in RTL)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.primary,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: Spacing.iconSm,
                        color: color.onPrimary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        locale.assignBoxBestSuggestion,
                        style: getSemiBoldStyle(
                          color: color.onPrimary,
                          fontSize: FontSize.size11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            // Main Content Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Radio button (Far right in RTL)
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? color.primary : color.outlineVariant,
                  size: Spacing.iconMd,
                ),
                const SizedBox(width: Spacing.xs),
                // Driver Name & Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 95),
                      child: Text(
                        driver.name,
                        style: getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm - Spacing.border,
                        vertical: Spacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.dispatcherBadgeNewSurface,
                        borderRadius: BorderRadius.circular(
                          Spacing.radiusPill,
                        ),
                      ),
                      child: Text(
                        driver.statusText,
                        style: getSemiBoldStyle(
                          color: color.dispatcherBadgeNew,
                          fontSize: FontSize.size9,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm - Spacing.border,
                        vertical: Spacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.surface,
                        borderRadius: BorderRadius.circular(
                          Spacing.radiusPill,
                        ),
                        border: Border.all(color: color.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: Spacing.md - 2,
                            color: color.primary,
                          ),
                          const SizedBox(width: Spacing.xs / 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              driver.tagText,
                              style: getSemiBoldStyle(
                                color: color.primary,
                                fontSize: FontSize.size9,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Spacing.xs),
                // Middle Metrics Section
                Expanded(
                  child: Row(
                    children: [
                      // Current Load Column
                      if (driver.currentLoadText != null)
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
                                  driver.currentLoadText!,
                                  style: getBoldStyle(
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
                      // Distance & Expected Completion Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                driver.distanceText,
                                style: getBoldStyle(
                                  color: color.onSurface,
                                  fontSize: FontSize.size11,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            if (driver.expectedCompletionText != null) ...[
                              const SizedBox(height: Spacing.xs / 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: Spacing.md,
                                    color: color.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: Spacing.xs / 2),
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
                              const SizedBox(height: Spacing.xs / 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  driver.expectedCompletionText!,
                                  style: getBoldStyle(
                                    color: color.onSurface,
                                    fontSize: FontSize.size11,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                // Avatar (Far Left in RTL)
                Container(
                  width: Spacing.buttonSmallHeight,
                  height: Spacing.buttonSmallHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.surface,
                    border: Border.all(
                      color: color.primary,
                      width: Spacing.border,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: Spacing.iconMd,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

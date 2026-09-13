import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/box_tracking_step_entity.dart';

class BoxTrackingTimelineStepItem extends StatelessWidget {
  const BoxTrackingTimelineStepItem({
    super.key,
    required this.step,
    required this.isLast,
  });

  final BoxTrackingStepEntity step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    Widget indicator;
    if (step.isCompleted) {
      indicator = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.tertiary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          size: Spacing.iconXs,
          color: color.onTertiary,
        ),
      );
    } else if (step.isActive) {
      indicator = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.primary,
            width: Spacing.border * 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      indicator = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: color.outline,
            width: Spacing.border,
          ),
        ),
      );
    }

    final contentWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: step.isActive ? Spacing.sm : Spacing.zero,
        vertical: step.isActive ? Spacing.xs : Spacing.zero,
      ),
      decoration: step.isActive
          ? BoxDecoration(
              color: color.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              step.title,
              style: step.isActive
                  ? getBoldStyle(
                      color: color.primary,
                      fontSize: FontSize.size14,
                    )
                  : getMediumStyle(
                      color: step.isCompleted
                          ? color.onSurface
                          : color.onSurfaceVariant,
                      fontSize: FontSize.size14,
                    ),
            ),
          ),
          if (step.time != null) ...[
            const SizedBox(width: Spacing.xs),
            Text(
              step.time!,
              style: getRegularStyle(
                color: step.isActive ? color.primary : color.onSurfaceVariant,
                fontSize: FontSize.size12,
              ),
            ),
          ],
        ],
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              indicator,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: Spacing.xs / 2,
                    ),
                    color: step.isCompleted
                        ? color.tertiary
                        : color.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? Spacing.zero : Spacing.md,
              ),
              child: contentWidget,
            ),
          ),
        ],
      ),
    );
  }
}

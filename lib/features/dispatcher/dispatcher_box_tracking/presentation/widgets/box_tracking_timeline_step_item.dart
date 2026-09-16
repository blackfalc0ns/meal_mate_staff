import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
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
    this.isFirst = false,
    this.prevStepCompleted = false,
  });

  final BoxTrackingStepEntity step;
  final bool isLast;
  final bool isFirst;
  final bool prevStepCompleted;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    // 1. Indicator Widget
    Widget indicator;
    if (step.isCompleted) {
      indicator = Container(
        width: Spacing.iconMd,
        height: Spacing.iconMd,
        decoration: BoxDecoration(
          color: color.tertiary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, size: Spacing.iconSm, color: color.onTertiary),
      );
    } else if (step.isActive) {
      indicator = Container(
        width: Spacing.iconMd,
        height: Spacing.iconMd,
        decoration: BoxDecoration(
          color: color.infoSurface,
          shape: BoxShape.circle,
          border: Border.all(color: color.info, width: Spacing.border * 2),
        ),
        child: Center(
          child: Container(
            width: Spacing.sm,
            height: Spacing.sm,
            decoration: BoxDecoration(
              color: color.info,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      indicator = Container(
        width: Spacing.iconMd,
        height: Spacing.iconMd,
        decoration: BoxDecoration(
          color: color.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color.outline, width: Spacing.border * 2),
        ),
      );
    }

    // 2. Card Styling
    final Color cardBg;
    final Border? cardBorder;
    final Color iconBg;
    final Color iconColor;

    if (step.isCompleted) {
      cardBg = color.tertiaryContainer;
      cardBorder = Border.all(
        color: color.tertiary.withValues(alpha: 0.2),
        width: Spacing.border,
      );
      iconBg = color.tertiary.withValues(alpha: 0.15);
      iconColor = color.tertiary;
    } else if (step.isActive) {
      cardBg = color.surface;
      cardBorder = Border.all(color: color.info, width: Spacing.border * 1.5);
      iconBg = color.infoSurface;
      iconColor = color.info;
    } else {
      cardBg = color.surface;
      cardBorder = Border.all(color: color.outline, width: Spacing.border);
      iconBg = color.surfaceContainerHighest;
      iconColor = color.onSurfaceVariant;
    }

    final cardWidget = Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: cardBorder,
      ),
      child: Row(
        children: [
          // Icon Container (Start in directionality)
          Container(
            width: Spacing.buttonSmallHeight,
            height: Spacing.buttonSmallHeight,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Icon(
              step.icon ?? _fallbackIcon(step.title),
              size: Spacing.iconMd,
              color: iconColor,
            ),
          ),
          const SizedBox(width: Spacing.md),
          // Text Content (End in directionality)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step.title,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size13,
                  ),
                ),
                if (step.description != null &&
                    step.description!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs / 2),
                  Text(
                    step.description!,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (step.time != null && step.time!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs / 2),
                  Text(
                    step.time!,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // 3. Line Colors
    final activeLineColor = color.tertiary;
    final inactiveLineColor = color.outline;

    final topLineColor = isFirst
        ? color.transparent
        : (prevStepCompleted ? activeLineColor : inactiveLineColor);

    final bottomLineColor = isLast
        ? color.transparent
        : (step.isCompleted ? activeLineColor : inactiveLineColor);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator Rail (Start in directionality)
          SizedBox(
            width: Spacing.iconMd,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: Spacing.border * 2,
                    color: topLineColor,
                  ),
                ),
                indicator,
                Expanded(
                  child: Container(
                    width: Spacing.border * 2,
                    color: bottomLineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Step Card (End in directionality)
          Expanded(child: cardWidget),
        ],
      ),
    );
  }

  IconData _fallbackIcon(String title) {
    if (title.contains('مطعم') || title.toLowerCase().contains('ready')) {
      return Icons.storefront_rounded;
    }
    if (title.contains('سائق') || title.toLowerCase().contains('driver')) {
      return Icons.person_rounded;
    }
    if (title.contains('طريق') || title.toLowerCase().contains('way')) {
      return Icons.local_shipping_rounded;
    }
    return Icons.assignment_turned_in_outlined;
  }
}

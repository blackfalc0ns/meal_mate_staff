import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_ticket_timeline_step.dart';

class DriverSupportTicketTimelineStepTile extends StatelessWidget {
  const DriverSupportTicketTimelineStepTile({
    super.key,
    required this.step,
    required this.isFirst,
    required this.isLast,
  });

  final DriverSupportTicketTimelineStep step;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    Widget indicator;
    switch (step.state) {
      case DriverTicketStepState.completed:
        indicator = Container(
          width: Spacing.iconMd,
          height: Spacing.iconMd,
          decoration: BoxDecoration(
            color: color.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: Spacing.iconSm,
            color: color.onPrimary,
          ),
        );
        break;
      case DriverTicketStepState.inProgress:
        indicator = Container(
          width: Spacing.iconMd,
          height: Spacing.iconMd,
          decoration: BoxDecoration(
            color: color.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color.primary, width: 2),
          ),
          child: Icon(
            Icons.access_time_rounded,
            size: Spacing.iconXs,
            color: color.primary,
          ),
        );
        break;
      case DriverTicketStepState.pending:
        if (isLast) {
          indicator = Container(
            width: Spacing.iconMd,
            height: Spacing.iconMd,
            decoration: BoxDecoration(
              color: color.outline.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: Spacing.iconSm,
              color: color.surface,
            ),
          );
        } else {
          indicator = Container(
            width: Spacing.iconMd,
            height: Spacing.iconMd,
            decoration: BoxDecoration(
              color: color.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.outline.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          );
        }
        break;
    }

    final isHighlighted = step.isHighlighted;
    final stepContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          step.title,
          style: getBoldStyle(
            fontSize: FontSize.size13,
            color: isHighlighted
                ? color.primary
                : (isLast && step.state == DriverTicketStepState.pending
                    ? color.onSurfaceVariant
                    : color.onSurface),
          ),
        ),
        if (step.description != null) ...[
          const SizedBox(height: Spacing.xs / 2),
          Text(
            step.description!,
            style: getRegularStyle(
              fontSize: FontSize.size11,
              color: color.onSurfaceVariant,
            ),
          ),
        ],
        if (step.timestamp != null) ...[
          const SizedBox(height: Spacing.xs / 2),
          Text(
            step.timestamp!,
            style: getRegularStyle(
              fontSize: FontSize.size10,
              color: isHighlighted
                  ? color.primary.withValues(alpha: 0.75)
                  : color.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (isHighlighted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
            ),
            child: Row(
              children: [
                indicator,
                const SizedBox(width: Spacing.md),
                Expanded(child: stepContent),
              ],
            ),
          ),
          if (!isLast)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: Spacing.md),
                  child: Container(
                    width: Spacing.iconMd,
                    height: 18,
                    alignment: Alignment.center,
                    child: Container(
                      width: 2,
                      height: 18,
                      color: step.state == DriverTicketStepState.completed
                          ? color.primary.withValues(alpha: 0.3)
                          : color.outline.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: Spacing.md),
            child: Column(
              children: [
                indicator,
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: Spacing.xs / 2),
                      color: step.state == DriverTicketStepState.completed
                          ? color.primary.withValues(alpha: 0.3)
                          : color.outline.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: isLast ? Spacing.zero : Spacing.base,
                top: Spacing.xs / 2,
              ),
              child: stepContent,
            ),
          ),
        ],
      ),
    );
  }
}

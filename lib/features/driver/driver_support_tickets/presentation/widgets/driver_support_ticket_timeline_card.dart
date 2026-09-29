import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_ticket_timeline_step.dart';
import 'driver_support_ticket_timeline_step_tile.dart';

class DriverSupportTicketTimelineCard extends StatelessWidget {
  const DriverSupportTicketTimelineCard({super.key, required this.steps});

  final List<DriverSupportTicketTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.driverSupportTicketTimelineTitle,
            style: getBoldStyle(
              fontSize: FontSize.size15,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Column(
            children: [
              for (var i = 0; i < steps.length; i++)
                DriverSupportTicketTimelineStepTile(
                  step: steps[i],
                  isFirst: i == 0,
                  isLast: i == steps.length - 1,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/box_tracking_step_entity.dart';
import 'box_tracking_timeline_step_item.dart';

class BoxTrackingTimelineCard extends StatelessWidget {
  const BoxTrackingTimelineCard({super.key, required this.steps});

  final List<BoxTrackingStepEntity> steps;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            locale.boxTrackingTimelineTitle,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size16,
            ),
          ),
          const SizedBox(height: Spacing.md),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return BoxTrackingTimelineStepItem(
                step: steps[index],
                isFirst: index == 0,
                isLast: index == steps.length - 1,
                prevStepCompleted: index > 0 && steps[index - 1].isCompleted,
              );
            },
          ),
        ],
      ),
    );
  }
}

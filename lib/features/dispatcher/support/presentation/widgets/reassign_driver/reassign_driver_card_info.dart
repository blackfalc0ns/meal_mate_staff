import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/reassign_driver_candidate_entity.dart';

class ReassignDriverCardInfo extends StatelessWidget {
  const ReassignDriverCardInfo({super.key, required this.candidate});

  final ReassignDriverCandidateEntity candidate;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          candidate.name,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xs / 2),
        Text(
          candidate.code,
          style: getBoldStyle(color: color.primary, fontSize: FontSize.size10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xs / 2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.xs / 2,
          ),
          decoration: BoxDecoration(
            color: color.tertiaryContainer,
            borderRadius: BorderRadius.circular(Spacing.radiusXs),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Spacing.xs,
                height: Spacing.xs,
                decoration: BoxDecoration(
                  color: color.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Spacing.xs / 2),
              Flexible(
                child: Text(
                  locale.reassignDriverAvailableNow,
                  style: getBoldStyle(
                    color: color.tertiary,
                    fontSize: FontSize.size10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

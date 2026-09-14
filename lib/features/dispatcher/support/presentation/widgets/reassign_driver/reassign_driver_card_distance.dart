import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/reassign_driver_candidate_entity.dart';

class ReassignDriverCardDistance extends StatelessWidget {
  const ReassignDriverCardDistance({super.key, required this.candidate});

  final ReassignDriverCandidateEntity candidate;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${candidate.distanceKm.toStringAsFixed(1)} كم',
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: Spacing.iconXs - Spacing.border * 2,
              color: color.primary,
            ),
            const SizedBox(width: Spacing.xs / 2),
            Flexible(
              child: Text(
                locale.reassignDriverFromYourLocation,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

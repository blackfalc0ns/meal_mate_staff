import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/reassign_driver_candidate_entity.dart';

class ReassignDriverCardAvatar extends StatelessWidget {
  const ReassignDriverCardAvatar({super.key, required this.candidate});

  final ReassignDriverCandidateEntity candidate;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: Spacing.buttonSmallHeight,
          height: Spacing.buttonSmallHeight,
          decoration: BoxDecoration(
            color: color.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child:
              candidate.avatarAsset != null && candidate.avatarAsset!.isNotEmpty
              ? Image.asset(
                  candidate.avatarAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person_rounded,
                    size: Spacing.iconMd,
                    color: color.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  size: Spacing.iconMd,
                  color: color.onSurfaceVariant.withValues(alpha: 0.5),
                ),
        ),
        PositionedDirectional(
          bottom: Spacing.zero,
          end: Spacing.zero,
          child: Container(
            width: Spacing.sm + Spacing.border,
            height: Spacing.sm + Spacing.border,
            decoration: BoxDecoration(
              color: candidate.isAvailable
                  ? color.tertiary
                  : color.onSurfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: color.surface, width: Spacing.border),
            ),
          ),
        ),
      ],
    );
  }
}

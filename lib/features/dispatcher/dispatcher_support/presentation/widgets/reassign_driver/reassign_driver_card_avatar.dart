import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/widget/app_cached_network_image.dart';
import '../../../domain/entities/reassign_driver_candidate_entity.dart';

class ReassignDriverCardAvatar extends StatelessWidget {
  const ReassignDriverCardAvatar({super.key, required this.candidate});

  final ReassignDriverCandidateEntity candidate;

  Widget _buildAvatarImage(BuildContext context) {
    return AppCachedNetworkImage(
      imageUrl: candidate.avatarUrl,
      fit: BoxFit.cover,
    );
  }

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
          child: _buildAvatarImage(context),
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

import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/reassign_driver_candidate_entity.dart';
import 'reassign_driver_card_avatar.dart';
import 'reassign_driver_card_distance.dart';
import 'reassign_driver_card_info.dart';
import 'reassign_driver_card_stats.dart';
import 'reassign_driver_radio_indicator.dart';

class ReassignDriverCard extends StatelessWidget {
  const ReassignDriverCard({
    super.key,
    required this.candidate,
    required this.isSelected,
    this.onSelected,
  });

  final ReassignDriverCandidateEntity candidate;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final borderColor = isSelected ? color.primary : color.outlineVariant;
    final borderWidth = isSelected ? Spacing.border * 1.5 : Spacing.border;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReassignDriverCardAvatar(candidate: candidate),
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 4,
                child: ReassignDriverCardInfo(candidate: candidate),
              ),
              VerticalDivider(
                color: color.outlineVariant,
                width: Spacing.xs * 2,
                thickness: Spacing.border,
              ),
              Expanded(
                flex: 3,
                child: ReassignDriverCardStats(candidate: candidate),
              ),
              VerticalDivider(
                color: color.outlineVariant,
                width: Spacing.xs * 2,
                thickness: Spacing.border,
              ),
              Expanded(
                flex: 3,
                child: ReassignDriverCardDistance(candidate: candidate),
              ),
              const SizedBox(width: Spacing.xs),
              ReassignDriverRadioIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

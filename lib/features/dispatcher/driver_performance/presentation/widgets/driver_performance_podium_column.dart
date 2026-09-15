import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_podium_entry_entity.dart';
import 'driver_performance_podium_badge.dart';

class DriverPerformancePodiumColumn extends StatelessWidget {
  const DriverPerformancePodiumColumn({
    super.key,
    required this.entry,
  });

  final DriverPodiumEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isRank1 = entry.rank == 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: isRank1
            ? color.primary.withValues(alpha: 0.08)
            : color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: isRank1
              ? color.primary.withValues(alpha: 0.3)
              : color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.surfaceContainerHighest,
                  border: Border.all(
                    color: color.primary.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: color.onSurfaceVariant,
                ),
              ),
              PositionedDirectional(
                top: -2,
                start: -4,
                child: DriverPerformancePodiumBadge(rank: entry.rank),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            entry.name,
            style: getBoldStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size11,
              color: color.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs / 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.rating.toStringAsFixed(1),
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size13,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.star_rounded,
                size: 14,
                color: color.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

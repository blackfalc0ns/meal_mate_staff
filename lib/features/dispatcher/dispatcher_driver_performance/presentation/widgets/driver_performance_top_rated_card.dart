import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_podium_entry_entity.dart';
import 'driver_performance_podium_column.dart';

class DriverPerformanceTopRatedCard extends StatelessWidget {
  const DriverPerformanceTopRatedCard({super.key, required this.entries});

  final List<DriverPodiumEntryEntity> entries;

  DriverPodiumEntryEntity? _findRank(int rank) {
    try {
      return entries.firstWhere((e) => e.rank == rank);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final rank1 = _findRank(1);
    final rank2 = _findRank(2);
    final rank3 = _findRank(3);

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            locale.driverPerformanceTopRatedTitle,
            style: getBoldStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size13,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              if (rank2 != null)
                Expanded(child: DriverPerformancePodiumColumn(entry: rank2)),
              if (rank2 != null && rank1 != null)
                const SizedBox(width: Spacing.sm),
              if (rank1 != null)
                Expanded(child: DriverPerformancePodiumColumn(entry: rank1)),
              if ((rank2 != null || rank1 != null) && rank3 != null)
                const SizedBox(width: Spacing.sm),
              if (rank3 != null)
                Expanded(child: DriverPerformancePodiumColumn(entry: rank3)),
            ],
          ),
        ],
      ),
    );
  }
}

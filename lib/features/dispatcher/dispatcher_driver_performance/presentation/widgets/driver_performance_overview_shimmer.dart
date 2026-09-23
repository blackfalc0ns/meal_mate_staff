import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverPerformanceOverviewShimmer extends StatelessWidget {
  const DriverPerformanceOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segmented tabs placeholder
          ShimmerWidget(
            height: 44,
            borderRadius: Spacing.radiusMd,
          ),
          const SizedBox(height: Spacing.md),

          // 5 KPI blocks
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsetsDirectional.only(end: Spacing.sm),
                  child: ShimmerWidget(
                    width: 66,
                    height: 93,
                    borderRadius: 9,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Drivers Table Card Shimmer
          Container(
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
                const ShimmerWidget(width: 140, height: 18, borderRadius: 4),
                const SizedBox(height: Spacing.md),
                const ShimmerWidget(height: 24, borderRadius: 4),
                const SizedBox(height: Spacing.sm),
                ...List.generate(
                  4,
                  (index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: Spacing.xs),
                    child: ShimmerWidget(height: 42, borderRadius: 6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Distribution Card Shimmer
          Container(
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
                const ShimmerWidget(width: 160, height: 18, borderRadius: 4),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    const ShimmerWidget(width: 110, height: 110, borderRadius: 55),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: ShimmerWidget(height: 20, borderRadius: 4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Top Rated Podium Shimmer
          Container(
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
                const ShimmerWidget(width: 150, height: 18, borderRadius: 4),
                const SizedBox(height: Spacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    ShimmerWidget(width: 75, height: 120, borderRadius: 8),
                    ShimmerWidget(width: 85, height: 150, borderRadius: 8),
                    ShimmerWidget(width: 75, height: 100, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }
}

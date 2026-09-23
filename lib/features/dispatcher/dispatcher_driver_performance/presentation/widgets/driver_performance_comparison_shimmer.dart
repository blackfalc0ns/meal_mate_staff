import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverPerformanceComparisonShimmer extends StatelessWidget {
  const DriverPerformanceComparisonShimmer({super.key});

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

          // Horizontally scrollable comparison card placeholder
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget(width: 160, height: 18, borderRadius: 4),
                const SizedBox(height: Spacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: List.generate(
                      4,
                      (index) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: Spacing.md),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(Spacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Spacing.radiusSm),
                            border: Border.all(
                              color: color.outlineVariant.withValues(alpha: 0.4),
                              width: Spacing.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const ShimmerWidget(width: 44, height: 44, borderRadius: 22),
                              const SizedBox(height: Spacing.xs),
                              const ShimmerWidget(width: 80, height: 14, borderRadius: 3),
                              const SizedBox(height: Spacing.xs),
                              const ShimmerWidget(width: 50, height: 10, borderRadius: 3),
                              const SizedBox(height: Spacing.md),
                              ...List.generate(
                                7,
                                (metricIndex) => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: Spacing.xs),
                                  child: ShimmerWidget(height: 22, borderRadius: 4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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

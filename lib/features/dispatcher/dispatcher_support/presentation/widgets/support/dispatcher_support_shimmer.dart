import 'package:flutter/material.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/widget/shimmer_widget.dart';

class DispatcherSupportShimmer extends StatelessWidget {
  const DispatcherSupportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI bar shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              children: [
                const Expanded(
                  flex: 11,
                  child: ShimmerWidget(
                    height: 52,
                    borderRadius: Spacing.dispatcherCardRadius,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                ...List.generate(
                  3,
                  (_) => const Expanded(
                    flex: 7,
                    child: Padding(
                      padding: EdgeInsets.only(left: Spacing.xs),
                      child: ShimmerWidget(
                        height: 52,
                        borderRadius: Spacing.dispatcherCardRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Search bar shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.base),
            child: ShimmerWidget(
              height: 48,
              borderRadius: Spacing.buttonSmallRadius,
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Filter chips shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              children: List.generate(
                4,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: Spacing.xs),
                  child: ShimmerWidget(
                    width: 72,
                    height: Spacing.dispatcherSupportFilterChipHeight,
                    borderRadius: Spacing.buttonSmallRadius,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Issue cards shimmer
          ...List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.xs,
              ),
              child: ShimmerWidget(
                height: 128,
                borderRadius: Spacing.dispatcherCardRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

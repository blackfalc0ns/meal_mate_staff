import 'package:flutter/material.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';
import 'operations_cards_shimmer.dart';

class DispatcherOperationsShimmer extends StatelessWidget {
  const DispatcherOperationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search + date filter shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              children: [
                Expanded(child: ShimmerWidget(height: 38, borderRadius: 10)),
                SizedBox(width: Spacing.sm),
                ShimmerWidget(width: 100, height: 38, borderRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // 2. Five status chips shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(left: Spacing.xs),
                    child: ShimmerWidget(
                      width: 75,
                      height: 32,
                      borderRadius: Spacing.radiusPill,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // 3. Three operations cards shimmer
          const OperationsCardsShimmer(),

          const SizedBox(height: Spacing.sm),

          // 4. Pagination bar shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerWidget(
                  width: 80,
                  height: 36,
                  borderRadius: Spacing.buttonSmallRadius,
                ),
                ShimmerWidget(width: 70, height: 24, borderRadius: 4),
                ShimmerWidget(
                  width: 80,
                  height: 36,
                  borderRadius: Spacing.buttonSmallRadius,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

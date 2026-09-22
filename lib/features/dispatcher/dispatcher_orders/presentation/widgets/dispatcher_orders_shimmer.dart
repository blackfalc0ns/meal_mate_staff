import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DispatcherOrdersShimmer extends StatelessWidget {
  const DispatcherOrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget(
                width: 140,
                height: 24,
                borderRadius: Spacing.radiusSm,
              ),
              ShimmerWidget(
                width: 80,
                height: 24,
                borderRadius: Spacing.radiusPill,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Title section shimmer
          const ShimmerWidget(
            width: 100,
            height: 24,
            borderRadius: Spacing.radiusSm,
          ),
          const SizedBox(height: Spacing.xs),
          const ShimmerWidget(
            width: 220,
            height: 16,
            borderRadius: Spacing.radiusSm,
          ),
          const SizedBox(height: Spacing.md),

          // Counters (4 metrics) shimmer
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : Spacing.xs / 2,
                    right: index == 3 ? 0 : Spacing.xs / 2,
                  ),
                  child: const ShimmerWidget(
                    height: 56,
                    borderRadius: Spacing.radiusSm,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Filter chips shimmer
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: Spacing.xs),
                  child: ShimmerWidget(
                    width: index == 0 ? 60 : 80,
                    height: 32,
                    borderRadius: Spacing.radiusPill,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // 3 cards shimmer
          const DispatcherCardsShimmer(padding: EdgeInsets.zero),
        ],
      ),
    );
  }
}

class DispatcherCardsShimmer extends StatelessWidget {
  const DispatcherCardsShimmer({
    super.key,
    this.itemCount = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: Spacing.screenH),
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          itemCount,
          (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
              border: Border.all(color: color.outline, width: Spacing.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget(
                      width: 90,
                      height: 20,
                      borderRadius: Spacing.radiusXs,
                    ),
                    ShimmerWidget(
                      width: 60,
                      height: 24,
                      borderRadius: Spacing.radiusPill,
                    ),
                  ],
                ),
                SizedBox(height: Spacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget(
                      width: 70,
                      height: 32,
                      borderRadius: Spacing.radiusSm,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShimmerWidget(
                          width: 100,
                          height: 14,
                          borderRadius: Spacing.radiusXs,
                        ),
                        SizedBox(height: Spacing.xs),
                        ShimmerWidget(
                          width: 80,
                          height: 14,
                          borderRadius: Spacing.radiusXs,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Spacing.md),
                ShimmerWidget(
                  width: 160,
                  height: 28,
                  borderRadius: Spacing.radiusPill,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

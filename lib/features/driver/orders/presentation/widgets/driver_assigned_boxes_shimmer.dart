import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverAssignedBoxesShimmer extends StatelessWidget {
  const DriverAssignedBoxesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Logo
          Center(
            child: ShimmerWidget(
              width: 120,
              height: 36,
              borderRadius: Spacing.radiusSm,
            ),
          ),
          SizedBox(height: Spacing.md),

          // Title & Delivery Mode Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(
                    width: 130,
                    height: 20,
                    borderRadius: Spacing.radiusXs,
                  ),
                  SizedBox(height: Spacing.xs),
                  ShimmerWidget(
                    width: 170,
                    height: 14,
                    borderRadius: Spacing.radiusXs,
                  ),
                ],
              ),
              ShimmerWidget(
                width: 90,
                height: 24,
                borderRadius: Spacing.radiusPill,
              ),
            ],
          ),
          SizedBox(height: Spacing.md),

          // Stats Banner
          ShimmerWidget(height: 96, borderRadius: Spacing.radiusMd),
          SizedBox(height: Spacing.md),

          // Filter Bar
          Row(
            children: [
              Expanded(
                child: ShimmerWidget(
                  height: Spacing.dispatcherMapButtonHeight,
                  borderRadius: Spacing.radiusSm,
                ),
              ),
              SizedBox(width: Spacing.sm),
              ShimmerWidget(
                width: 38,
                height: 38,
                borderRadius: Spacing.radiusSm,
              ),
            ],
          ),
          SizedBox(height: Spacing.md),

          // 4 Box Cards Shimmer
          DriverAssignedBoxesCardsShimmer(),
        ],
      ),
    );
  }
}

class DriverAssignedBoxesCardsShimmer extends StatelessWidget {
  const DriverAssignedBoxesCardsShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: Spacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.6),
              width: Spacing.border,
            ),
          ),
          child: const Row(
            children: [
              // Action / Status column
              ShimmerWidget(
                width: 64,
                height: 32,
                borderRadius: Spacing.radiusSm,
              ),
              SizedBox(width: Spacing.xs),
              // Vertical divider
              SizedBox(width: Spacing.border, height: 48),
              SizedBox(width: Spacing.xs),
              // Meals & Area
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(width: 50, height: 14),
                    SizedBox(height: Spacing.xs),
                    ShimmerWidget(width: 70, height: 12),
                  ],
                ),
              ),
              SizedBox(width: Spacing.xs),
              // IDs
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(width: 60, height: 14),
                    SizedBox(height: Spacing.xs),
                    ShimmerWidget(width: 50, height: 12),
                  ],
                ),
              ),
              SizedBox(width: Spacing.xs),
              // Icon Badge
              ShimmerWidget(
                width: 44,
                height: 44,
                borderRadius: Spacing.radiusSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/widget/shimmer_widget.dart';

class DispatcherReassignShimmer extends StatelessWidget {
  const DispatcherReassignShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.screenV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Card shimmer
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(color: Colors.black12, width: Spacing.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget(width: 80, height: 18, borderRadius: Spacing.radiusXs),
                        SizedBox(height: Spacing.xs),
                        ShimmerWidget(width: 160, height: 16),
                        SizedBox(height: Spacing.xs / 2),
                        ShimmerWidget(width: 70, height: 12),
                      ],
                    ),
                    ShimmerWidget(
                      width: Spacing.buttonSmallHeight + Spacing.xs,
                      height: Spacing.buttonSmallHeight + Spacing.xs,
                      borderRadius: 100,
                    ),
                  ],
                ),
                SizedBox(height: Spacing.sm),
                Divider(color: Colors.black12, height: Spacing.border),
                SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(child: ShimmerWidget(height: 32)),
                    SizedBox(width: Spacing.xs),
                    Expanded(child: ShimmerWidget(height: 32)),
                    SizedBox(width: Spacing.xs),
                    Expanded(child: ShimmerWidget(height: 32)),
                  ],
                ),
                SizedBox(height: Spacing.sm),
                Divider(color: Colors.black12, height: Spacing.border),
                SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(child: ShimmerWidget(height: 36)),
                    SizedBox(width: Spacing.xs),
                    Expanded(child: ShimmerWidget(height: 36)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.base),

          // Header shimmer
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(width: 110, height: 16),
                  SizedBox(height: Spacing.xs / 2),
                  ShimmerWidget(width: 180, height: 12),
                ],
              ),
              ShimmerWidget(width: 60, height: 28, borderRadius: Spacing.radiusSm),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Candidate cards shimmer (4 items)
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Spacing.cardRadius),
                  border: Border.all(color: Colors.black12, width: Spacing.border),
                ),
                child: const Row(
                  children: [
                    ShimmerWidget(
                      width: Spacing.buttonSmallHeight,
                      height: Spacing.buttonSmallHeight,
                      borderRadius: 100,
                    ),
                    SizedBox(width: Spacing.sm),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget(width: 90, height: 14),
                          SizedBox(height: Spacing.xs / 2),
                          ShimmerWidget(width: 50, height: 12),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShimmerWidget(width: 40, height: 12),
                          SizedBox(height: Spacing.xs / 2),
                          ShimmerWidget(width: 35, height: 12),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShimmerWidget(width: 45, height: 12),
                          SizedBox(height: Spacing.xs / 2),
                          ShimmerWidget(width: 40, height: 12),
                        ],
                      ),
                    ),
                    SizedBox(width: Spacing.xs),
                    ShimmerWidget(width: 20, height: 20, borderRadius: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

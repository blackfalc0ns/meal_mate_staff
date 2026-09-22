import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/widget/shimmer_widget.dart';

class DispatcherIssueDetailsShimmer extends StatelessWidget {
  const DispatcherIssueDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header shimmer
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(color: Colors.black12, width: Spacing.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(
                      width: Spacing.dispatcherDriverAvatarSize,
                      height: Spacing.dispatcherDriverAvatarSize,
                      borderRadius: 100,
                    ),
                    SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget(width: 140, height: 16),
                          SizedBox(height: Spacing.xs),
                          ShimmerWidget(width: 90, height: 12),
                        ],
                      ),
                    ),
                    ShimmerWidget(
                      width: 50,
                      height: 22,
                      borderRadius: Spacing.radiusXs,
                    ),
                  ],
                ),
                SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ShimmerWidget(
                        height: 38,
                        borderRadius: Spacing.radiusXs,
                      ),
                    ),
                    SizedBox(width: Spacing.sm),
                    Expanded(
                      child: ShimmerWidget(
                        height: 38,
                        borderRadius: Spacing.radiusXs,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Driver card shimmer
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(color: Colors.black12, width: Spacing.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: 90, height: 14),
                SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    ShimmerWidget(
                      width: Spacing.buttonSmallHeight * 1.15,
                      height: Spacing.buttonSmallHeight * 1.15,
                      borderRadius: 100,
                    ),
                    SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget(width: 120, height: 14),
                          SizedBox(height: Spacing.xs),
                          ShimmerWidget(width: 70, height: 12),
                        ],
                      ),
                    ),
                    ShimmerWidget(width: 36, height: 36, borderRadius: 100),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Description shimmer
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(color: Colors.black12, width: Spacing.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: 100, height: 14),
                SizedBox(height: Spacing.sm),
                ShimmerWidget(width: double.infinity, height: 14),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(width: 200, height: 14),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Trip info shimmer
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(color: Colors.black12, width: Spacing.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: 130, height: 14),
                SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(child: ShimmerWidget(height: 32)),
                    SizedBox(width: Spacing.sm),
                    Expanded(child: ShimmerWidget(height: 32)),
                  ],
                ),
                SizedBox(height: Spacing.sm),
                ShimmerWidget(width: double.infinity, height: 32),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Action buttons shimmer
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(color: Colors.black12, width: Spacing.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: 100, height: 14),
                SizedBox(height: Spacing.sm),
                ShimmerWidget(
                  width: double.infinity,
                  height: Spacing.accountStatusButtonHeight,
                  borderRadius: Spacing.buttonSmallRadius,
                ),
                SizedBox(height: Spacing.sm),
                ShimmerWidget(
                  width: double.infinity,
                  height: Spacing.accountStatusButtonHeight,
                  borderRadius: Spacing.buttonSmallRadius,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    );
  }
}

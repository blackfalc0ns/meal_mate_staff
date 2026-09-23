import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class BoxTrackingShimmer extends StatelessWidget {
  const BoxTrackingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.screenV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Card Shimmer
          ShimmerWidget(
            key: Key('box_tracking_shimmer_header'),
            height: 100,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.md),

          // 2. Timeline Card Shimmer
          SizedBox(
            key: Key('box_tracking_shimmer_timeline'),
            child: Column(
              children: [
                ShimmerWidget(
                  key: Key('box_tracking_shimmer_step_0'),
                  height: 60,
                  borderRadius: Spacing.cardRadius,
                ),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(
                  key: Key('box_tracking_shimmer_step_1'),
                  height: 60,
                  borderRadius: Spacing.cardRadius,
                ),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(
                  key: Key('box_tracking_shimmer_step_2'),
                  height: 60,
                  borderRadius: Spacing.cardRadius,
                ),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(
                  key: Key('box_tracking_shimmer_step_3'),
                  height: 60,
                  borderRadius: Spacing.cardRadius,
                ),
              ],
            ),
          ),
          SizedBox(height: Spacing.md),

          // 3. Driver Card Shimmer
          ShimmerWidget(
            key: Key('box_tracking_shimmer_driver'),
            height: 80,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.md),

          // 4. Details Card Shimmer
          ShimmerWidget(
            key: Key('box_tracking_shimmer_details'),
            height: 140,
            borderRadius: Spacing.cardRadius,
          ),
          SizedBox(height: Spacing.lg),

          // 5. Report Issue Button Placeholder
          ShimmerWidget(
            key: Key('box_tracking_shimmer_report_button'),
            height: Spacing.buttonHeight,
            borderRadius: Spacing.radiusLg,
          ),
          SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }
}

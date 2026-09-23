import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class AssignBoxShimmer extends StatelessWidget {
  const AssignBoxShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.screenV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Box summary card block
          ShimmerWidget(
            key: Key('assign_box_shimmer_box_card'),
            height: 140,
            borderRadius: Spacing.radiusLg,
          ),
          SizedBox(height: Spacing.base),

          // 2. Recommended driver block
          ShimmerWidget(
            key: Key('assign_box_shimmer_recommended_card'),
            height: 80,
            borderRadius: Spacing.radiusLg,
          ),
          SizedBox(height: Spacing.lg),

          // 3. Candidates header
          Row(
            key: Key('assign_box_shimmer_candidates_header'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget(width: 100, height: 18),
              ShimmerWidget(width: 60, height: 16),
            ],
          ),
          SizedBox(height: Spacing.sm),

          // 4. Four candidate rows
          ShimmerWidget(
            key: Key('assign_box_shimmer_candidate_row_0'),
            height: 72,
            borderRadius: Spacing.radiusLg,
          ),
          SizedBox(height: Spacing.sm),
          ShimmerWidget(
            key: Key('assign_box_shimmer_candidate_row_1'),
            height: 72,
            borderRadius: Spacing.radiusLg,
          ),
          SizedBox(height: Spacing.sm),
          ShimmerWidget(
            key: Key('assign_box_shimmer_candidate_row_2'),
            height: 72,
            borderRadius: Spacing.radiusLg,
          ),
          SizedBox(height: Spacing.sm),
          ShimmerWidget(
            key: Key('assign_box_shimmer_candidate_row_3'),
            height: 72,
            borderRadius: Spacing.radiusLg,
          ),
          SizedBox(height: Spacing.base),

          // 5. Bottom action placeholders
          Row(
            key: Key('assign_box_shimmer_bottom_actions'),
            children: [
              Expanded(
                child: ShimmerWidget(
                  height: 48,
                  borderRadius: Spacing.radiusMd,
                ),
              ),
              SizedBox(width: Spacing.sm),
              Expanded(
                flex: 2,
                child: ShimmerWidget(
                  height: 48,
                  borderRadius: Spacing.radiusMd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

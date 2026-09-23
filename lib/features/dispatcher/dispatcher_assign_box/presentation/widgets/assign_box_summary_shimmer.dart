import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class AssignBoxSummaryShimmer extends StatelessWidget {
  const AssignBoxSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle placeholder
          Center(
            child: ShimmerWidget(
              width: 40,
              height: 4,
              borderRadius: Spacing.radiusSm,
            ),
          ),
          SizedBox(height: Spacing.base),

          // 1. Identity & barcode block
          ShimmerWidget(
            key: Key('assign_box_summary_shimmer_identity'),
            height: 70,
            borderRadius: Spacing.radiusMd,
          ),
          SizedBox(height: Spacing.md),

          // 2. Customer & address block
          ShimmerWidget(
            key: Key('assign_box_summary_shimmer_customer'),
            height: 90,
            borderRadius: Spacing.radiusMd,
          ),
          SizedBox(height: Spacing.md),

          // Section header for meals
          ShimmerWidget(width: 80, height: 16),
          SizedBox(height: Spacing.sm),

          // 3. At least three meal rows
          ShimmerWidget(
            key: Key('assign_box_summary_shimmer_meal_0'),
            height: 48,
            borderRadius: Spacing.radiusMd,
          ),
          SizedBox(height: Spacing.xs),
          ShimmerWidget(
            key: Key('assign_box_summary_shimmer_meal_1'),
            height: 48,
            borderRadius: Spacing.radiusMd,
          ),
          SizedBox(height: Spacing.xs),
          ShimmerWidget(
            key: Key('assign_box_summary_shimmer_meal_2'),
            height: 48,
            borderRadius: Spacing.radiusMd,
          ),
        ],
      ),
    );
  }
}

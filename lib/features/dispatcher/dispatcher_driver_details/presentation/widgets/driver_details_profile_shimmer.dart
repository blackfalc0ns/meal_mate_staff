import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverDetailsProfileShimmer extends StatelessWidget {
  const DriverDetailsProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerWidget(width: 56, height: 56, borderRadius: 100),
          SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerWidget(width: 120, height: 16),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(width: 70, height: 14),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(width: 95, height: 12),
              ],
            ),
          ),
          SizedBox(width: Spacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerWidget(width: 75, height: 22, borderRadius: 100),
              SizedBox(height: Spacing.xs),
              ShimmerWidget(width: 65, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

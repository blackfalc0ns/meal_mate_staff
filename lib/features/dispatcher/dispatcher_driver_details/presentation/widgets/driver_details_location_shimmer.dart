import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverDetailsLocationShimmer extends StatelessWidget {
  const DriverDetailsLocationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerWidget(width: 100, height: 16),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(width: 80, height: 12),
                SizedBox(height: Spacing.xs / 2),
                ShimmerWidget(width: 65, height: 11),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(width: 110, height: 12),
                SizedBox(height: Spacing.xs / 2),
                ShimmerWidget(width: 85, height: 12),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(width: 105, height: 32, borderRadius: 8),
              ],
            ),
          ),
          SizedBox(width: Spacing.sm),
          Expanded(
            flex: 4,
            child: ShimmerWidget(
              height: 130,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }
}

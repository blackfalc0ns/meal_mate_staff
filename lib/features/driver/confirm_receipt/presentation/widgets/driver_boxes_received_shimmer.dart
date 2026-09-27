import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverBoxesReceivedShimmer extends StatelessWidget {
  const DriverBoxesReceivedShimmer({super.key});

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
          SizedBox(height: Spacing.base),
          // Success banner
          ShimmerWidget(height: 72, borderRadius: Spacing.cardRadius),
          SizedBox(height: Spacing.sm),
          // Info summary card with 3 sections
          ShimmerWidget(height: 84, borderRadius: Spacing.cardRadius),
          SizedBox(height: Spacing.lg),
          // Received boxes header bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget(width: 140, height: 20, borderRadius: Spacing.radiusXs),
              ShimmerWidget(width: 32, height: 20, borderRadius: Spacing.radiusPill),
            ],
          ),
          SizedBox(height: Spacing.sm),
          // 4-5 received box cards
          for (int i = 0; i < 4; i++) ...[
            ShimmerWidget(height: 68, borderRadius: Spacing.cardRadius),
            SizedBox(height: Spacing.sm),
          ],
          SizedBox(height: Spacing.xs),
          // Safety banner
          ShimmerWidget(height: 52, borderRadius: Spacing.cardRadius),
          SizedBox(height: Spacing.lg),
          // Start delivery action button
          ShimmerWidget(height: Spacing.buttonHeight, borderRadius: Spacing.buttonRadius),
          SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }
}

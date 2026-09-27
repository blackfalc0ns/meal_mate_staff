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
          const SizedBox(height: Spacing.base),
          // Success banner
          const ShimmerWidget(height: 72, borderRadius: Spacing.cardRadius),
          const SizedBox(height: Spacing.sm),
          // Info summary card with 3 sections
          const ShimmerWidget(height: 84, borderRadius: Spacing.cardRadius),
          const SizedBox(height: Spacing.lg),
          // Received boxes header bar
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget(
                width: 140,
                height: 20,
                borderRadius: Spacing.radiusXs,
              ),
              ShimmerWidget(
                width: 32,
                height: 20,
                borderRadius: Spacing.radiusPill,
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          // 4-5 received box cards
          for (int i = 0; i < 4; i++) ...[
            const ShimmerWidget(height: 68, borderRadius: Spacing.cardRadius),
            const SizedBox(height: Spacing.sm),
          ],
          const SizedBox(height: Spacing.xs),
          // Safety banner
          const ShimmerWidget(height: 52, borderRadius: Spacing.cardRadius),
          const SizedBox(height: Spacing.lg),
          // Start delivery action button
          const ShimmerWidget(
            height: Spacing.buttonHeight,
            borderRadius: Spacing.buttonRadius,
          ),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }
}

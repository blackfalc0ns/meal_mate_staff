import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';

class DriverHomeShimmer extends StatelessWidget {
  const DriverHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / identity row skeleton
          Row(
            children: [
              ShimmerWidget(
                width: 48,
                height: 48,
                borderRadius: Spacing.radiusPill,
              ),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(width: 140, height: 16),
                    SizedBox(height: Spacing.xs),
                    ShimmerWidget(width: 80, height: 12),
                  ],
                ),
              ),
              ShimmerWidget(
                width: 70,
                height: 28,
                borderRadius: Spacing.radiusPill,
              ),
            ],
          ),
          SizedBox(height: Spacing.base),

          // Main hero card skeleton (Goal / Status / Illustration card)
          ShimmerWidget(height: 190, borderRadius: Spacing.cardRadius),
          SizedBox(height: Spacing.base),

          // Secondary section skeleton (Current order / today summary)
          ShimmerWidget(height: 140, borderRadius: Spacing.cardRadius),
          SizedBox(height: Spacing.base),

          // Performance cards skeleton row
          Row(
            children: [
              Expanded(
                child: ShimmerWidget(
                  height: 90,
                  borderRadius: Spacing.cardRadius,
                ),
              ),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: ShimmerWidget(
                  height: 90,
                  borderRadius: Spacing.cardRadius,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

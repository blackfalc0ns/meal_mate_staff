import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';
import 'driver_details_boxes_shimmer.dart';
import 'driver_details_location_shimmer.dart';
import 'driver_details_profile_shimmer.dart';

class DriverDetailsShimmer extends StatelessWidget {
  const DriverDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xs),
          const DriverDetailsProfileShimmer(),
          const SizedBox(height: Spacing.xs),
          // 4 KPIs
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerWidget(
                    height: 60,
                    borderRadius: Spacing.cardRadius,
                  ),
                ),
                SizedBox(width: Spacing.xs * 1.5),
                Expanded(
                  child: ShimmerWidget(
                    height: 60,
                    borderRadius: Spacing.cardRadius,
                  ),
                ),
                SizedBox(width: Spacing.xs * 1.5),
                Expanded(
                  child: ShimmerWidget(
                    height: 60,
                    borderRadius: Spacing.cardRadius,
                  ),
                ),
                SizedBox(width: Spacing.xs * 1.5),
                Expanded(
                  child: ShimmerWidget(
                    height: 60,
                    borderRadius: Spacing.cardRadius,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xs),
          const DriverDetailsLocationShimmer(),
          const SizedBox(height: Spacing.xs),
          const DriverDetailsBoxesShimmer(),
          const SizedBox(height: Spacing.xs),
          // Daily Performance Summary
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.xs,
            ),
            child: Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Spacing.cardRadius),
                border: Border.all(
                  color: color.outlineVariant,
                  width: Spacing.border,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerWidget(width: 160, height: 16),
                  SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: ShimmerWidget(height: 50)),
                      SizedBox(width: Spacing.sm),
                      Expanded(child: ShimmerWidget(height: 50)),
                      SizedBox(width: Spacing.sm),
                      Expanded(child: ShimmerWidget(height: 50)),
                      SizedBox(width: Spacing.sm),
                      Expanded(child: ShimmerWidget(height: 50)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          // Action buttons
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerWidget(
                    height: Spacing.dispatcherActionBtnSmallHeight,
                    borderRadius: Spacing.buttonSmallRadius,
                  ),
                ),
                SizedBox(width: Spacing.sm),
                Expanded(
                  child: ShimmerWidget(
                    height: Spacing.dispatcherActionBtnSmallHeight,
                    borderRadius: Spacing.buttonSmallRadius,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }
}

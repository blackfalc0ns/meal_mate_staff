import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DispatcherMapShimmer extends StatelessWidget {
  const DispatcherMapShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background map shimmer
        const Positioned.fill(
          child: ShimmerWidget(
            borderRadius: 0,
          ),
        ),

        // Top overlay: Header & KPI bar shimmer
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerWidget(
                        width: 40,
                        height: 40,
                        borderRadius: Spacing.radiusPill,
                      ),
                      ShimmerWidget(
                        width: 140,
                        height: 24,
                        borderRadius: Spacing.radiusSm,
                      ),
                      ShimmerWidget(
                        width: 40,
                        height: 40,
                        borderRadius: Spacing.radiusPill,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),

                  // KPI row (4 cards)
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : Spacing.xs / 2,
                            right: index == 3 ? 0 : Spacing.xs / 2,
                          ),
                          child: const ShimmerWidget(
                            height: 64,
                            borderRadius: Spacing.radiusSm,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Controls placeholder (floating right/bottom-ish)
        PositionedDirectional(
          end: Spacing.base,
          bottom: Spacing.dispatcherMapBottomCarouselHeight + Spacing.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ShimmerWidget(
                width: Spacing.dispatcherMapControlBtnSize,
                height: Spacing.dispatcherMapControlBtnSize,
                borderRadius: Spacing.radiusPill,
              ),
              SizedBox(height: Spacing.sm),
              ShimmerWidget(
                width: Spacing.dispatcherMapZoomWidth,
                height: Spacing.dispatcherMapZoomHeight,
                borderRadius: Spacing.radiusPill,
              ),
            ],
          ),
        ),

        // Bottom carousel shimmer
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: Spacing.dispatcherMapBottomCarouselHeight,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base,
                  vertical: Spacing.xs,
                ),
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
                itemBuilder: (_, _) => const ShimmerWidget(
                  width: Spacing.dispatcherMapBottomCardWidth,
                  height: Spacing.dispatcherMapBottomCardHeight,
                  borderRadius: Spacing.dispatcherCardRadius,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DispatcherHomeShimmer extends StatelessWidget {
  const DispatcherHomeShimmer({super.key});

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
          // 1. Header Shimmer
          _buildHeader(),
          const SizedBox(height: Spacing.base),

          // 2. KPI Row Shimmer
          _buildKpis(),
          const SizedBox(height: Spacing.lg),

          // 3. Quick Actions Shimmer
          _buildQuickActions(),
          const SizedBox(height: Spacing.lg),

          // 4. Map Card Shimmer
          _buildMapCard(),
          const SizedBox(height: Spacing.lg),

          // 5. Operations & Drivers Row Shimmer
          _buildOperationsDrivers(),
          const SizedBox(height: Spacing.lg),

          // 6. Areas Section Shimmer
          _buildAreas(),
          const SizedBox(height: Spacing.lg),

          // 7. Alert Banner Shimmer
          const ShimmerWidget(height: 64, borderRadius: Spacing.cardRadius),
          const SizedBox(height: Spacing.bottomNavHeight + Spacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ShimmerWidget(width: 18, height: 18, borderRadius: Spacing.radiusXs),
                SizedBox(width: Spacing.xs),
                ShimmerWidget(width: 100, height: 14, borderRadius: Spacing.radiusSm),
                SizedBox(width: Spacing.xs),
                ShimmerWidget(width: 54, height: 16, borderRadius: Spacing.radiusXs),
              ],
            ),
            ShimmerWidget(width: 36, height: 36, borderRadius: Spacing.radiusSm),
          ],
        ),
        SizedBox(height: Spacing.md),
        ShimmerWidget(width: 130, height: 18, borderRadius: Spacing.radiusSm),
        SizedBox(height: Spacing.xs),
        ShimmerWidget(width: 210, height: 12, borderRadius: Spacing.radiusXs),
      ],
    );
  }

  Widget _buildKpis() {
    return Row(
      children: List.generate(
        4,
        (index) => const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
            child: ShimmerWidget(
              height: 90,
              borderRadius: Spacing.radiusMd,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: List.generate(
        4,
        (index) => const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
            child: ShimmerWidget(
              height: 72,
              borderRadius: Spacing.radiusMd,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: 110, height: 14, borderRadius: Spacing.radiusSm),
                SizedBox(height: Spacing.xs),
                ShimmerWidget(width: 160, height: 10, borderRadius: Spacing.radiusXs),
              ],
            ),
            ShimmerWidget(width: 80, height: 26, borderRadius: Spacing.radiusPill),
          ],
        ),
        SizedBox(height: Spacing.sm),
        ShimmerWidget(height: 210, borderRadius: Spacing.cardRadius),
      ],
    );
  }

  Widget _buildOperationsDrivers() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 9,
          child: ShimmerWidget(
            height: 230,
            borderRadius: Spacing.cardRadius,
          ),
        ),
        SizedBox(width: Spacing.sm),
        Expanded(
          flex: 11,
          child: ShimmerWidget(
            height: 230,
            borderRadius: Spacing.cardRadius,
          ),
        ),
      ],
    );
  }

  Widget _buildAreas() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget(width: 90, height: 14, borderRadius: Spacing.radiusSm),
            ShimmerWidget(width: 50, height: 12, borderRadius: Spacing.radiusXs),
          ],
        ),
        SizedBox(height: Spacing.sm),
        ShimmerWidget(height: 80, borderRadius: Spacing.cardRadius),
      ],
    );
  }
}

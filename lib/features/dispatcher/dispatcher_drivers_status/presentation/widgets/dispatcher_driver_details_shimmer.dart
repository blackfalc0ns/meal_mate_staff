import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DispatcherDriverDetailsShimmer extends StatelessWidget {
  const DispatcherDriverDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile card placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Container(
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                border: Border.all(
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  width: Spacing.border,
                ),
              ),
              child: const Row(
                children: [
                  ShimmerWidget(width: 56, height: 56, borderRadius: 28),
                  SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget(width: 140, height: 18),
                        SizedBox(height: Spacing.xs),
                        ShimmerWidget(width: 90, height: 14),
                      ],
                    ),
                  ),
                  ShimmerWidget(width: 44, height: 24, borderRadius: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          // 4 Metric cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsetsDirectional.only(
                      end: index < 3 ? Spacing.xs : Spacing.zero,
                    ),
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                        width: Spacing.border,
                      ),
                    ),
                    padding: const EdgeInsets.all(Spacing.xs),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerWidget(width: 32, height: 14),
                        SizedBox(height: Spacing.xs),
                        ShimmerWidget(width: 44, height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          // Contact Card placeholder
          _buildPlaceholderCard(context),
          const SizedBox(height: Spacing.sm),
          // Vehicle Card placeholder
          _buildPlaceholderCard(context),
          const SizedBox(height: Spacing.sm),
          // Location Card placeholder
          _buildPlaceholderCard(context),
          const SizedBox(height: Spacing.sm),
          // Performance Card placeholder
          _buildPlaceholderCard(context),
          const SizedBox(height: Spacing.sm),
          // Documents Card placeholder
          _buildPlaceholderCard(context),
          const SizedBox(height: Spacing.bottomNavHeight + Spacing.lg),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: Spacing.border,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerWidget(width: 120, height: 14),
            SizedBox(height: Spacing.sm),
            Row(
              children: [
                ShimmerWidget(width: 36, height: 36, borderRadius: 8),
                SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(width: double.infinity, height: 12),
                      SizedBox(height: Spacing.xs),
                      ShimmerWidget(width: 100, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverSupportTicketsListShimmer extends StatelessWidget {
  const DriverSupportTicketsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.screenV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search skeleton
          const ShimmerWidget(
            height: 48,
            borderRadius: Spacing.radiusMd,
          ),
          const SizedBox(height: Spacing.md),

          // KPI row skeleton
          const Row(
            children: [
              Expanded(
                child: ShimmerWidget(
                  height: 64,
                  borderRadius: Spacing.cardRadius,
                ),
              ),
              SizedBox(width: Spacing.xs),
              Expanded(
                child: ShimmerWidget(
                  height: 64,
                  borderRadius: Spacing.cardRadius,
                ),
              ),
              SizedBox(width: Spacing.xs),
              Expanded(
                child: ShimmerWidget(
                  height: 64,
                  borderRadius: Spacing.cardRadius,
                ),
              ),
              SizedBox(width: Spacing.xs),
              Expanded(
                child: ShimmerWidget(
                  height: 64,
                  borderRadius: Spacing.cardRadius,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Ticket cards skeleton
          for (var i = 0; i < 4; i++) ...[
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Spacing.cardRadius),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
                  width: Spacing.border,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerWidget(
                        width: 80,
                        height: 16,
                        borderRadius: Spacing.radiusSm,
                      ),
                      ShimmerWidget(
                        width: 70,
                        height: 22,
                        borderRadius: Spacing.radiusPill,
                      ),
                    ],
                  ),
                  SizedBox(height: Spacing.sm),
                  ShimmerWidget(
                    width: 160,
                    height: 14,
                    borderRadius: Spacing.radiusSm,
                  ),
                  SizedBox(height: Spacing.xs),
                  ShimmerWidget(
                    width: 100,
                    height: 12,
                    borderRadius: Spacing.radiusSm,
                  ),
                  SizedBox(height: Spacing.sm),
                  Divider(height: 1),
                  SizedBox(height: Spacing.xs + 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerWidget(
                        width: 110,
                        height: 12,
                        borderRadius: Spacing.radiusSm,
                      ),
                      ShimmerWidget(
                        width: 70,
                        height: 12,
                        borderRadius: Spacing.radiusSm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

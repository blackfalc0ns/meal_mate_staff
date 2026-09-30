import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverNotificationsShimmer extends StatelessWidget {
  const DriverNotificationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter tabs placeholder
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(right: Spacing.xs),
                child: ShimmerWidget(
                  width: 70,
                  height: 32,
                  borderRadius: Spacing.radiusMd,
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          // Section header placeholder
          const ShimmerWidget(width: 80, height: 16, borderRadius: 4),
          const SizedBox(height: Spacing.sm),
          // Notification cards
          ...List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                border: Border.all(color: color.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerWidget(
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerWidget(
                          width: 120,
                          height: 14,
                          borderRadius: 4,
                        ),
                        SizedBox(height: Spacing.xs),
                        ShimmerWidget(
                          width: double.infinity,
                          height: 12,
                          borderRadius: 4,
                        ),
                        SizedBox(height: Spacing.xs),
                        ShimmerWidget(
                          width: 60,
                          height: 10,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

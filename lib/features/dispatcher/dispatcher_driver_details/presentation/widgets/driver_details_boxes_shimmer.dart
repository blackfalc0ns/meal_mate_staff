import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverDetailsBoxesShimmer extends StatelessWidget {
  const DriverDetailsBoxesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.xs / 2,
              ),
              child: ShimmerWidget(width: 140, height: 16),
            ),
            SizedBox(height: Spacing.xs),
            ShimmerWidget(
              width: double.infinity,
              height: 72,
              borderRadius: Spacing.radiusSm,
            ),
            SizedBox(height: Spacing.xs),
            ShimmerWidget(
              width: double.infinity,
              height: 72,
              borderRadius: Spacing.radiusSm,
            ),
          ],
        ),
      ),
    );
  }
}

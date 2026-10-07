import 'package:flutter/material.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverActiveDeliveryShimmer extends StatelessWidget {
  const DriverActiveDeliveryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final mapHeight = (screenHeight - 460).clamp(280.0, 440.0);

    Widget shimmerBox({required double height, double? width, double borderRadius = Spacing.radiusSm}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xs),
          shimmerBox(height: 24, width: 140),
          const SizedBox(height: Spacing.xs),
          shimmerBox(height: 16, width: 220),
          const SizedBox(height: Spacing.base),
          shimmerBox(height: mapHeight, borderRadius: Spacing.cardRadius),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(color: color.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    shimmerBox(height: 44, width: 44, borderRadius: Spacing.radiusMd),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          shimmerBox(height: 12, width: 80),
                          const SizedBox(height: Spacing.xs),
                          shimmerBox(height: 16, width: 150),
                          const SizedBox(height: Spacing.xs),
                          shimmerBox(height: 12, width: 180),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                shimmerBox(height: 36, width: double.infinity),
                const SizedBox(height: Spacing.sm),
                shimmerBox(height: 40, width: double.infinity),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          shimmerBox(height: Spacing.buttonHeight, borderRadius: Spacing.radiusMd),
        ],
      ),
    );
  }
}

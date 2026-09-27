import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusShimmer extends StatelessWidget {
  const DispatcherDriversStatusShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final shimmerColor = color.outlineVariant.withValues(alpha: 0.25);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      ),
                    ),
                    Container(
                      width: 140,
                      height: 20,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Container(
                  width: 120,
                  height: 28,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // 4 KPI cards
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
                    height: 70,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // Search & Filter & Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // Cards
          ...List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.xs,
              ),
              height: 120,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

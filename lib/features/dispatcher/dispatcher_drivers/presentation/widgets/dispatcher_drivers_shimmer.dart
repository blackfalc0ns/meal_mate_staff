import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';
import 'dispatcher_drivers_vertical_divider.dart';

/// Full screen shimmer shown during the initial load of Dispatcher Drivers.
class DispatcherDriversShimmer extends StatelessWidget {
  const DispatcherDriversShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. View switcher shimmer
          _DispatcherDriversViewSwitcherShimmer(),
          SizedBox(height: Spacing.xs),

          // 2. Area chips shimmer
          _DispatcherDriversAreaChipsShimmer(),
          SizedBox(height: Spacing.xs),

          // 3. KPI card shimmer
          DispatcherDriversKpiShimmer(),
          SizedBox(height: Spacing.sm),

          // 4. Section header shimmer
          DispatcherDriversSectionHeaderShimmer(),
          SizedBox(height: Spacing.xs),

          // 5. Driver cards shimmer (3 cards)
          DispatcherDriversCardShimmer(),
          DispatcherDriversCardShimmer(),
          DispatcherDriversCardShimmer(),

          SizedBox(height: Spacing.xs),

          // 6. Map button shimmer
          _DispatcherDriversMapButtonShimmer(),
          SizedBox(height: Spacing.base),
        ],
      ),
    );
  }
}

/// Shimmer for the top View Switcher tabs (All Drivers / By Area).
class _DispatcherDriversViewSwitcherShimmer extends StatelessWidget {
  const _DispatcherDriversViewSwitcherShimmer();

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Container(
        height:
            Spacing.registrationSmallButtonHeight +
            Spacing.border +
            Spacing.border,
        decoration: BoxDecoration(
          color: color.primaryContainer,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
        ),
        padding: const EdgeInsets.all(Spacing.xs - Spacing.border),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: color.surface,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerWidget(
                      width: Spacing.iconXs,
                      height: Spacing.iconXs,
                      borderRadius: Spacing.radiusPill,
                    ),
                    SizedBox(width: Spacing.xs),
                    ShimmerWidget(
                      width: 58,
                      height: 12,
                      borderRadius: Spacing.radiusXs,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            const Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerWidget(
                    width: Spacing.iconXs,
                    height: Spacing.iconXs,
                    borderRadius: Spacing.radiusPill,
                  ),
                  SizedBox(width: Spacing.xs),
                  ShimmerWidget(
                    width: 66,
                    height: 12,
                    borderRadius: Spacing.radiusXs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for the horizontal area chips list.
class _DispatcherDriversAreaChipsShimmer extends StatelessWidget {
  const _DispatcherDriversAreaChipsShimmer();

  Widget _buildChip(
    BuildContext context, {
    required bool isSelected,
    required double labelWidth,
  }) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? color.primary.withValues(alpha: 0.12)
            : color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        border: Border.all(
          color: color.outlineVariant.withValues(
            alpha: Spacing.hairline + Spacing.border / 10,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ShimmerWidget(
            width: Spacing.iconXs,
            height: Spacing.iconXs,
            borderRadius: Spacing.radiusPill,
          ),
          const SizedBox(width: Spacing.xs),
          ShimmerWidget(
            width: labelWidth,
            height: 12,
            borderRadius: Spacing.radiusXs,
          ),
          const SizedBox(width: Spacing.xs),
          const ShimmerWidget(
            width: 18,
            height: 14,
            borderRadius: Spacing.radiusPill,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Spacing.registrationSmallButtonHeight + Spacing.border,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        children: [
          _buildChip(context, isSelected: true, labelWidth: 48),
          const SizedBox(width: Spacing.xs),
          _buildChip(context, isSelected: false, labelWidth: 76),
          const SizedBox(width: Spacing.xs),
          _buildChip(context, isSelected: false, labelWidth: 54),
          const SizedBox(width: Spacing.xs),
          _buildChip(context, isSelected: false, labelWidth: 62),
        ],
      ),
    );
  }
}

/// Shimmer accurately mirroring [DispatcherDriversKpiCard].
class DispatcherDriversKpiShimmer extends StatelessWidget {
  const DispatcherDriversKpiShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: Spacing.hairline),
          ),
        ),
        child: const Row(
          children: [
            Expanded(child: _KpiSegmentShimmer(labelWidth: 54, valueWidth: 20)),
            DispatcherDriversVerticalDivider(),
            Expanded(child: _KpiSegmentShimmer(labelWidth: 62, valueWidth: 18)),
            DispatcherDriversVerticalDivider(),
            Expanded(child: _KpiSegmentShimmer(labelWidth: 50, valueWidth: 22)),
          ],
        ),
      ),
    );
  }
}

class _KpiSegmentShimmer extends StatelessWidget {
  const _KpiSegmentShimmer({
    required this.labelWidth,
    required this.valueWidth,
  });

  final double labelWidth;
  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const ShimmerWidget(
          width: Spacing.xxl,
          height: Spacing.xxl,
          borderRadius: Spacing.radiusPill,
        ),
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerWidget(
                width: labelWidth,
                height: 10,
                borderRadius: Spacing.radiusXs,
              ),
              const SizedBox(height: Spacing.xs),
              ShimmerWidget(
                width: valueWidth,
                height: 16,
                borderRadius: Spacing.radiusXs,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shimmer accurately mirroring [DispatcherDriversSectionHeader].
class DispatcherDriversSectionHeaderShimmer extends StatelessWidget {
  const DispatcherDriversSectionHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const ShimmerWidget(
            width: 140,
            height: 18,
            borderRadius: Spacing.radiusXs,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
              border: Border.all(
                color: color.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerWidget(
                  width: Spacing.iconXs,
                  height: Spacing.iconXs,
                  borderRadius: Spacing.radiusPill,
                ),
                SizedBox(width: Spacing.xs),
                ShimmerWidget(
                  width: 36,
                  height: 12,
                  borderRadius: Spacing.radiusXs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer accurately mirroring [DispatcherDriversCard].
class DispatcherDriversCardShimmer extends StatelessWidget {
  const DispatcherDriversCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ShimmerWidget(
              width: Spacing.dispatcherDriverAvatarSize,
              height: Spacing.dispatcherDriverAvatarSize,
              borderRadius: Spacing.radiusPill,
            ),
            const SizedBox(width: Spacing.sm),
            Container(
              width: Spacing.border,
              height: Spacing.dispatcherCardDividerHeight,
              color: color.outlineVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                ShimmerWidget(
                                  width: 65,
                                  height: 11,
                                  borderRadius: Spacing.radiusXs,
                                ),
                                SizedBox(width: Spacing.xs),
                                ShimmerWidget(
                                  width: 18,
                                  height: 11,
                                  borderRadius: Spacing.radiusXs,
                                ),
                              ],
                            ),
                            SizedBox(height: Spacing.xs / 2),
                            ShimmerWidget(
                              width: 44,
                              height: 9,
                              borderRadius: Spacing.radiusXs,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Spacing.xs),
                      ShimmerWidget(
                        width: 46,
                        height: Spacing.dispatcherDriverBadgeHeight,
                        borderRadius: Spacing.radiusPill,
                      ),
                      SizedBox(width: Spacing.xs),
                      ShimmerWidget(
                        width: 58,
                        height: Spacing.dispatcherDriverActionBtnHeight,
                        borderRadius: Spacing.buttonSmallRadius,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _CardMetricItemShimmer(
                          surfaceColor: color.dispatcherMetricBoxSurface,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: _CardMetricItemShimmer(
                          surfaceColor: color.dispatcherMetricBoxSurface,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: _CardMetricItemShimmer(
                          surfaceColor: color.dispatcherMetricBoxSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMetricItemShimmer extends StatelessWidget {
  const _CardMetricItemShimmer({required this.surfaceColor});

  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Spacing.dispatcherMetricBoxHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.border,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(
          Spacing.registrationReviewCardRadius,
        ),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerWidget(
                width: Spacing.dispatcherMetricIconSize,
                height: Spacing.dispatcherMetricIconSize,
                borderRadius: Spacing.radiusXs,
              ),
              SizedBox(width: Spacing.border * 2),
              ShimmerWidget(
                width: 16,
                height: 10,
                borderRadius: Spacing.radiusXs,
              ),
            ],
          ),
          SizedBox(height: Spacing.border),
          ShimmerWidget(width: 36, height: 7, borderRadius: Spacing.radiusXs),
        ],
      ),
    );
  }
}

/// Shimmer for the bottom map button.
class _DispatcherDriversMapButtonShimmer extends StatelessWidget {
  const _DispatcherDriversMapButtonShimmer();

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Container(
        width: double.infinity,
        height: Spacing.dispatcherMapButtonHeight,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerWidget(
              width: Spacing.iconSm,
              height: Spacing.iconSm,
              borderRadius: Spacing.radiusXs,
            ),
            SizedBox(width: Spacing.xs),
            ShimmerWidget(
              width: 120,
              height: 14,
              borderRadius: Spacing.radiusXs,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';

class DriverMapShimmer extends StatefulWidget {
  const DriverMapShimmer({super.key});

  @override
  State<DriverMapShimmer> createState() => _DriverMapShimmerState();
}

class _DriverMapShimmerState extends State<DriverMapShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final color = context.colorScheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding =
        (bottomInset > Spacing.md ? bottomInset : Spacing.md) +
        Spacing.bottomNavHeight +
        Spacing.sm;

    final content = Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: color.surfaceContainerHighest.withValues(alpha: 0.35),
            child: Center(
              child: Icon(
                Icons.map_outlined,
                size: 72,
                color: color.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Stack(
            children: [
              PositionedDirectional(
                top: Spacing.xs,
                start: Spacing.screenH,
                end: Spacing.screenH,
                child: Container(
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: color.shadow.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          ShimmerWidget(
                            width: 40,
                            height: 40,
                            borderRadius: 20,
                          ),
                          SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerWidget(
                                  width: 50,
                                  height: 10,
                                  borderRadius: 4,
                                ),
                                SizedBox(height: 6),
                                ShimmerWidget(
                                  width: 110,
                                  height: 14,
                                  borderRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: Spacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ShimmerWidget(
                                  width: 60,
                                  height: 14,
                                  borderRadius: 4,
                                ),
                                SizedBox(height: 6),
                                ShimmerWidget(
                                  width: 80,
                                  height: 16,
                                  borderRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: Spacing.sm),
                          ShimmerWidget(
                            width: 44,
                            height: 44,
                            borderRadius: 22,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.md,
                        ),
                        child: Divider(
                          color: color.outline.withValues(alpha: 0.12),
                          height: 1,
                        ),
                      ),
                      const Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: ShimmerWidget(height: 32, borderRadius: 6),
                          ),
                          SizedBox(width: Spacing.xs),
                          Expanded(
                            flex: 3,
                            child: ShimmerWidget(height: 32, borderRadius: 6),
                          ),
                          SizedBox(width: Spacing.xs),
                          Expanded(
                            flex: 3,
                            child: ShimmerWidget(height: 32, borderRadius: 6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const PositionedDirectional(
                end: Spacing.screenH,
                top: 168,
                child: ShimmerWidget(
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                ),
              ),
              PositionedDirectional(
                start: Spacing.zero,
                end: Spacing.zero,
                bottom: bottomPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 165,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: Container(
                              width: 140,
                              height: 145,
                              padding: const EdgeInsets.all(Spacing.sm),
                              decoration: BoxDecoration(
                                color: color.surface,
                                borderRadius: BorderRadius.circular(
                                  Spacing.radiusXl,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  ShimmerWidget(
                                    width: 36,
                                    height: 36,
                                    borderRadius: 18,
                                  ),
                                  SizedBox(height: 8),
                                  ShimmerWidget(
                                    width: 80,
                                    height: 12,
                                    borderRadius: 4,
                                  ),
                                  SizedBox(height: 6),
                                  ShimmerWidget(
                                    width: 60,
                                    height: 10,
                                    borderRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Container(
                            width: 175,
                            height: 165,
                            padding: const EdgeInsets.all(Spacing.sm),
                            decoration: BoxDecoration(
                              color: color.surface,
                              borderRadius: BorderRadius.circular(
                                Spacing.radiusXl,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.shadow.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                ShimmerWidget(
                                  width: 42,
                                  height: 42,
                                  borderRadius: 21,
                                ),
                                SizedBox(height: 8),
                                ShimmerWidget(
                                  width: 100,
                                  height: 14,
                                  borderRadius: 4,
                                ),
                                SizedBox(height: 6),
                                ShimmerWidget(
                                  width: 70,
                                  height: 12,
                                  borderRadius: 4,
                                ),
                                SizedBox(height: 8),
                                ShimmerWidget(
                                  width: 90,
                                  height: 18,
                                  borderRadius: 9,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Opacity(
                            opacity: 0.5,
                            child: Container(
                              width: 140,
                              height: 145,
                              padding: const EdgeInsets.all(Spacing.sm),
                              decoration: BoxDecoration(
                                color: color.surface,
                                borderRadius: BorderRadius.circular(
                                  Spacing.radiusXl,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  ShimmerWidget(
                                    width: 36,
                                    height: 36,
                                    borderRadius: 18,
                                  ),
                                  SizedBox(height: 8),
                                  ShimmerWidget(
                                    width: 80,
                                    height: 12,
                                    borderRadius: 4,
                                  ),
                                  SizedBox(height: 6),
                                  ShimmerWidget(
                                    width: 60,
                                    height: 10,
                                    borderRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerWidget(width: 8, height: 8, borderRadius: 4),
                        SizedBox(width: 6),
                        ShimmerWidget(width: 18, height: 8, borderRadius: 4),
                        SizedBox(width: 6),
                        ShimmerWidget(width: 8, height: 8, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (disableAnimations || !TickerMode.valuesOf(context).enabled) {
      return content;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.4),
                Colors.grey.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: content,
    );
  }
}

class DriverMapNavigationShimmer extends StatelessWidget {
  const DriverMapNavigationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerWidget(width: 60, height: 16, borderRadius: 4),
          ShimmerWidget(width: 60, height: 16, borderRadius: 4),
          ShimmerWidget(width: 80, height: 16, borderRadius: 4),
          ShimmerWidget(width: 32, height: 32, borderRadius: 16),
        ],
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}

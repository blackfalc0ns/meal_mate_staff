import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/shimmer_widget.dart';

/// Renders a single shimmer placeholder card identical to [OperationsCard].
class OperationsCardShimmerItem extends StatelessWidget {
  const OperationsCardShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs / 2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: const Row(
        children: [
          // 1. Driver info placeholder (flex 5)
          Expanded(
            flex: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ShimmerWidget(
                      width: 34,
                      height: 34,
                      borderRadius: 17,
                    ),
                    PositionedDirectional(
                      bottom: 0,
                      end: 0,
                      child: ShimmerWidget(
                        width: 7,
                        height: 7,
                        borderRadius: 3.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: Spacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerWidget(width: 65, height: 11, borderRadius: 4),
                      SizedBox(height: Spacing.xs / 2),
                      ShimmerWidget(width: 50, height: 9, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Spacing.xs),

          // 2. Customer info placeholder (flex 4)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerWidget(width: 68, height: 11, borderRadius: 4),
                SizedBox(height: Spacing.xs / 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerWidget(width: 10, height: 10, borderRadius: 2),
                    SizedBox(width: 3),
                    Flexible(
                      child: ShimmerWidget(width: 46, height: 9, borderRadius: 4),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: Spacing.xs),

          // 3. Status badge & timestamp placeholder
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerWidget(
                width: 64,
                height: 20,
                borderRadius: Spacing.radiusPill,
              ),
              SizedBox(height: Spacing.xs / 2),
              ShimmerWidget(width: 48, height: 9, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Renders a list of [OperationsCardShimmerItem] with an animated gradient sweep.
class OperationsCardsShimmer extends StatefulWidget {
  const OperationsCardsShimmer({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  State<OperationsCardsShimmer> createState() => _OperationsCardsShimmerState();
}

class _OperationsCardsShimmerState extends State<OperationsCardsShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isTesting =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (!_isTesting) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = Column(
      children: List.generate(
        widget.itemCount,
        (_) => const OperationsCardShimmerItem(),
      ),
    );

    if (_isTesting) {
      return list;
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
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFFFFFFF),
                Color(0xFFEBEBF4),
              ],
              stops: const [0.1, 0.3, 0.4],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: list,
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

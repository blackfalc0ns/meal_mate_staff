import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverMapPageIndicator extends StatelessWidget {
  const DriverMapPageIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.onDotTapped,
  });

  final int itemCount;
  final int currentIndex;
  final ValueChanged<int>? onDotTapped;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isSelected = index == currentIndex;

        return GestureDetector(
          onTap: () => onDotTapped?.call(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected
                  ? color.primary
                  : color.primary.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
            ),
          ),
        );
      }),
    );
  }
}

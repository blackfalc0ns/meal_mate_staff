import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import 'meal_mate_logo_painter.dart';

class MealMateNavLogo extends StatelessWidget {
  const MealMateNavLogo({
    super.key,
    required this.isSelected,
    this.size = 21,
  });

  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return CustomPaint(
      size: Size(size, size),
      painter: MealMateLogoPainter(
        archColor: isSelected ? color.onPrimary : color.onSurfaceVariant,
        smileColor: color.secondary,
      ),
    );
  }
}

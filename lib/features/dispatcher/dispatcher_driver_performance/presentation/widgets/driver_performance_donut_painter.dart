import '../../../../../config/theme/colors.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../domain/entities/driver_performance_distribution_category.dart';
import '../../domain/entities/driver_performance_distribution_item_entity.dart';

class DriverPerformanceDonutPainter extends CustomPainter {
  const DriverPerformanceDonutPainter({
    required this.items,
    required this.colorScheme,
  });

  final List<DriverPerformanceDistributionItemEntity> items;
  final ColorScheme colorScheme;

  Color _getCategoryColor(DriverPerformanceDistributionCategory cat) {
    switch (cat) {
      case DriverPerformanceDistributionCategory.onTime:
        return colorScheme.success;
      case DriverPerformanceDistributionCategory.late:
        return colorScheme.warning;
      case DriverPerformanceDistributionCategory.failed:
        return colorScheme.error;
      case DriverPerformanceDistributionCategory.cancelled:
        return colorScheme.outline;
      case DriverPerformanceDistributionCategory.unknown:
        return colorScheme.outlineVariant;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.16;
    final radius = (size.width - strokeWidth) / 2;

    if (items.isEmpty) {
      final basePaint = Paint()
        ..color = colorScheme.outlineVariant.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, basePaint);
      return;
    }

    double startAngle = -pi / 2;

    for (final item in items) {
      final sweepAngle = (item.percentage / 100.0) * 2 * pi;
      final paint = Paint()
        ..color = _getCategoryColor(item.category)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DriverPerformanceDonutPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.colorScheme != colorScheme;
  }
}

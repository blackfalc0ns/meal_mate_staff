import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_chart_point_entity.dart';
import 'driver_performance_line_chart_painter.dart';

class DriverPerformanceLineChart extends StatelessWidget {
  const DriverPerformanceLineChart({
    super.key,
    required this.points,
    required this.lineColor,
    required this.gradientColors,
    required this.yLabels,
    this.xLabels = const ['00:00', '12:00', '24:00'],
  });

  final List<DriverPerformanceChartPointEntity> points;
  final Color lineColor;
  final List<Color> gradientColors;
  final List<String> yLabels;
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return CustomPaint(
      size: const Size(double.infinity, 80),
      painter: DriverPerformanceLineChartPainter(
        points: points,
        lineColor: lineColor,
        gradientColors: gradientColors,
        gridColor: color.outline.withValues(alpha: 0.3),
        textStyle: getRegularStyle(
          fontSize: FontSize.size9,
          color: color.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        yLabels: yLabels,
        xLabels: xLabels,
        isRtl: isRtl,
      ),
    );
  }
}

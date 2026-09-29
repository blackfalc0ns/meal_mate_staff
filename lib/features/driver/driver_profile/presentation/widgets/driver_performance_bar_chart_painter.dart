import 'package:flutter/material.dart';

import '../../domain/entities/driver_performance_chart_point_entity.dart';

class DriverPerformanceBarChartPainter extends CustomPainter {
  const DriverPerformanceBarChartPainter({
    required this.points,
    required this.barColor,
    required this.gridColor,
    required this.textStyle,
    required this.yLabels,
    required this.xLabels,
    required this.isRtl,
  });

  final List<DriverPerformanceChartPointEntity> points;
  final Color barColor;
  final Color gridColor;
  final TextStyle textStyle;
  final List<String> yLabels;
  final List<String> xLabels;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double yAxisWidth = 28.0;
    const double xAxisHeight = 14.0;

    final double chartLeft = isRtl ? 0 : yAxisWidth;
    final double chartRight = isRtl ? size.width - yAxisWidth : size.width;
    final double chartWidth = chartRight - chartLeft;
    const double chartTop = 4.0;
    final double chartBottom = size.height - xAxisHeight;
    final double chartHeight = chartBottom - chartTop;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // Draw horizontal grid lines and y labels
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final int yGridCount = yLabels.length;
    for (int i = 0; i < yGridCount; i++) {
      final double y = chartBottom - (i / (yGridCount - 1)) * chartHeight;
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );

      final textSpan = TextSpan(text: yLabels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isRtl ? TextAlign.start : TextAlign.end,
      )..layout(maxWidth: yAxisWidth);

      final double labelX = isRtl ? chartRight + 4 : 0;
      textPainter.paint(
        canvas,
        Offset(labelX, y - (textPainter.height / 2)),
      );
    }

    // Determine max value for bars
    double maxY = points.first.value;
    for (final p in points) {
      if (p.value > maxY) maxY = p.value;
    }
    if (maxY <= 0) maxY = 1;

    // Draw bars
    final int count = points.length;
    final double slotWidth = chartWidth / count;
    final double barWidth = (slotWidth * 0.45).clamp(3.0, 7.0);

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final double fraction = points[i].value / maxY;
      final double barHeight = fraction * chartHeight * 0.9;
      if (barHeight <= 0) continue;

      final double centerX = isRtl
          ? chartRight - ((i + 0.5) * slotWidth)
          : chartLeft + ((i + 0.5) * slotWidth);

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - (barWidth / 2),
          chartBottom - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(2.5),
      );

      canvas.drawRRect(barRect, barPaint);
    }

    // Draw x-axis labels
    final int xGridCount = xLabels.length;
    for (int i = 0; i < xGridCount; i++) {
      final double fraction = i / (xGridCount - 1);
      final double x = isRtl
          ? chartRight - (fraction * chartWidth)
          : chartLeft + (fraction * chartWidth);

      final textSpan = TextSpan(text: xLabels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      double textX = x - (textPainter.width / 2);
      if (textX < chartLeft) textX = chartLeft;
      if (textX + textPainter.width > chartRight) {
        textX = chartRight - textPainter.width;
      }
      textPainter.paint(canvas, Offset(textX, chartBottom + 2));
    }
  }

  @override
  bool shouldRepaint(covariant DriverPerformanceBarChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.barColor != barColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.isRtl != isRtl;
  }
}

import 'package:flutter/material.dart';

import '../../domain/entities/driver_performance_chart_point_entity.dart';

class DriverPerformanceLineChartPainter extends CustomPainter {
  const DriverPerformanceLineChartPainter({
    required this.points,
    required this.lineColor,
    required this.gradientColors,
    required this.gridColor,
    required this.textStyle,
    required this.yLabels,
    required this.xLabels,
    required this.isRtl,
  });

  final List<DriverPerformanceChartPointEntity> points;
  final Color lineColor;
  final List<Color> gradientColors;
  final Color gridColor;
  final TextStyle textStyle;
  final List<String> yLabels;
  final List<String> xLabels;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double yAxisWidth = 32.0;
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

    // Map points to canvas coordinates
    double minY = points.first.value;
    double maxY = points.first.value;
    for (final p in points) {
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }
    if (maxY == minY) {
      maxY = minY + 1;
      minY = 0;
    }

    final List<Offset> offsets = [];
    final int count = points.length;
    for (int i = 0; i < count; i++) {
      final double normalizedX = i / (count - 1);
      final double x = isRtl
          ? chartRight - (normalizedX * chartWidth)
          : chartLeft + (normalizedX * chartWidth);
      final double normalizedY = (points[i].value - minY) / (maxY - minY);
      final double y = chartBottom - (normalizedY * chartHeight * 0.85);
      offsets.add(Offset(x, y));
    }

    // Build smooth curve path
    final path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Fill area under path with gradient
    final fillPath = Path.from(path);
    final lastOffset = offsets.last;
    final firstOffset = offsets.first;
    fillPath.lineTo(lastOffset.dx, chartBottom);
    fillPath.lineTo(firstOffset.dx, chartBottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(Rect.fromLTRB(chartLeft, chartTop, chartRight, chartBottom))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

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
  bool shouldRepaint(covariant DriverPerformanceLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.isRtl != isRtl;
  }
}

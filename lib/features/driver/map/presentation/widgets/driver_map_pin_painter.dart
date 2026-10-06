import 'dart:math' as math;
import 'package:flutter/material.dart';

class DriverMapPinPainter extends CustomPainter {
  const DriverMapPinPainter({
    required this.primaryColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final Color primaryColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final circleRadius = (size.width - 6.0) / 2;
    final centerY = circleRadius + 3.0;
    final tipY = size.height - 4.0;

    // 1. Draw ground contact shadow under the tip
    final groundShadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, size.height - 2.0),
        width: 14.0,
        height: 4.0,
      ),
      groundShadowPaint,
    );

    // 2. Compute teardrop pin path
    final distanceToTip = tipY - centerY;
    final sinAlpha = (circleRadius / distanceToTip).clamp(0.0, 1.0);
    final alpha = math.asin(sinAlpha);
    final cosAlpha = math.cos(alpha);
    final leftTangentX = centerX - circleRadius * cosAlpha;
    final leftTangentY = centerY + circleRadius * sinAlpha;

    final pinPath = Path();

    // Start at left tangent point
    pinPath.moveTo(leftTangentX, leftTangentY);

    // Arc around the top of the circle clockwise to the right tangent point
    final rect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: circleRadius,
    );
    final startAngle = math.pi - alpha;
    final sweepAngle = math.pi + 2 * alpha;
    pinPath.arcTo(rect, startAngle, sweepAngle, false);

    // Line from right tangent down to the bottom tip
    pinPath.lineTo(centerX, tipY);

    // Line from bottom tip back up to the left tangent
    pinPath.lineTo(leftTangentX, leftTangentY);
    pinPath.close();

    // 3. Draw soft pin drop shadow
    final pinShadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawPath(pinPath.shift(const Offset(0, 2)), pinShadowPaint);

    // 4. Draw pin fill (primary color)
    final fillPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, fillPaint);

    // 5. Draw pin border (surface white)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pinPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant DriverMapPinPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}

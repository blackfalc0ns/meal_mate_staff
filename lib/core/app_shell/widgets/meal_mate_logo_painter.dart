import 'package:flutter/material.dart';

class MealMateLogoPainter extends CustomPainter {
  const MealMateLogoPainter({
    required this.archColor,
    required this.smileColor,
  });

  final Color archColor;
  final Color smileColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Original Figma node 1631-3002 dimensions: 20.69 x 20.51
    final scaleX = size.width / 20.69;
    final scaleY = size.height / 20.51;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // M arch
    final archPaint = Paint()
      ..color = archColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final archPath = Path()
      ..moveTo(4.14, 18.2)
      ..lineTo(4.14, 7.47)
      ..cubicTo(4.14, 5.63, 5.63, 4.14, 7.47, 4.14)
      ..cubicTo(8.65, 4.14, 9.69, 4.76, 10.35, 5.7)
      ..cubicTo(11.01, 4.76, 12.05, 4.14, 13.23, 4.14)
      ..cubicTo(15.07, 4.14, 16.56, 5.63, 16.56, 7.47)
      ..lineTo(16.56, 18.2);

    canvas.drawPath(archPath, archPaint);

    // Smile curve with right droplet
    final smilePaint = Paint()
      ..color = smileColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(7.7, 12.0)
      ..quadraticBezierTo(10.35, 14.3, 13.0, 12.0);

    canvas.drawPath(smilePath, smilePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MealMateLogoPainter oldDelegate) {
    return oldDelegate.archColor != archColor ||
        oldDelegate.smileColor != smileColor;
  }
}

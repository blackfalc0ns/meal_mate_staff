import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class ReassignmentHeroIllustration extends StatelessWidget {
  const ReassignmentHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.sm),
        Center(
          child: SizedBox(
            width: 260,
            height: 125,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Curved Dashed Arrow across top
                Positioned(
                  top: 14,
                  left: 36,
                  right: 36,
                  height: 38,
                  child: CustomPaint(
                    painter: _DashedCurvedArrowPainter(
                      color: color.primary,
                    ),
                  ),
                ),
                // Left Driver Avatar
                Positioned(
                  top: 22,
                  left: 8,
                  child: _DriverAvatarCircle(color: color),
                ),
                // Right Driver Avatar
                Positioned(
                  top: 22,
                  right: 8,
                  child: _DriverAvatarCircle(color: color),
                ),
                // Center 3D Meal Box
                Positioned(
                  top: 36,
                  child: Image.asset(
                    AppAssets.dispatcherDriverBox3d,
                    width: 86,
                    height: 86,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.base),
        Text(
          locale.reassignRequestTitle,
          style: getBoldStyle(
            fontSize: FontSize.size20,
            color: color.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text(
            locale.reassignRequestDescription,
            style: getRegularStyle(
              fontSize: FontSize.size14,
              color: color.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _DriverAvatarCircle extends StatelessWidget {
  const _DriverAvatarCircle({required this.color});

  final ColorScheme color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          AppAssets.notificationIconUser,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _DashedCurvedArrowPainter extends CustomPainter {
  const _DashedCurvedArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final start = Offset(6, size.height - 4);
    final control = Offset(size.width / 2, -2);
    final end = Offset(size.width - 6, size.height - 4);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    const double dashWidth = 5.0;
    const double dashGap = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      final double totalLength = metric.length;
      final double stopDistance = math.max(0.0, totalLength - 8);

      while (distance < stopDistance) {
        final double nextDistance =
            (distance + dashWidth).clamp(0.0, stopDistance);
        canvas.drawPath(
          metric.extractPath(distance, nextDistance),
          strokePaint,
        );
        distance += dashWidth + dashGap;
      }

      // Arrowhead at the tip
      final tangent = metric.getTangentForOffset(totalLength - 1);
      if (tangent != null) {
        final angle = tangent.vector.direction;
        final arrowPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        final arrowPath = Path();
        const arrowLength = 9.0;
        const arrowAngle = 0.52; // radians

        final tip = end;
        final p1 = Offset(
          tip.dx - arrowLength * math.cos(angle - arrowAngle),
          tip.dy - arrowLength * math.sin(angle - arrowAngle),
        );
        final p2 = Offset(
          tip.dx - arrowLength * math.cos(angle + arrowAngle),
          tip.dy - arrowLength * math.sin(angle + arrowAngle),
        );

        arrowPath.moveTo(tip.dx, tip.dy);
        arrowPath.lineTo(p1.dx, p1.dy);
        arrowPath.lineTo(p2.dx, p2.dy);
        arrowPath.close();

        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCurvedArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxReceivedSuccessIllustration extends StatelessWidget {
  const DriverBoxReceivedSuccessIllustration({super.key});

  static const double _boxWidth = 140;
  static const double _boxHeight = 110;
  static const double _badgeSize = 44;
  static const double _sparkleSizeSm = 6;
  static const double _sparkleSizeMd = 8;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Center(
      child: SizedBox(
        width: _boxWidth + 60,
        height: _boxHeight + 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: Spacing.zero,
              child: Image.asset(
                Assets.driverBox3d,
                width: _boxWidth,
                height: _boxHeight,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: Spacing.sm,
              child: Container(
                width: _badgeSize,
                height: _badgeSize,
                decoration: BoxDecoration(
                  color: color.tertiary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: color.onTertiary,
                  size: Spacing.iconLg,
                ),
              ),
            ),
            Positioned(
              top: Spacing.zero,
              left: 40,
              child: Container(
                width: _sparkleSizeSm,
                height: _sparkleSizeSm,
                decoration: BoxDecoration(
                  color: color.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: Spacing.lg,
              left: 20,
              child: Container(
                width: _sparkleSizeMd,
                height: _sparkleSizeMd,
                decoration: BoxDecoration(
                  color: color.tertiary,
                  borderRadius: BorderRadius.circular(Spacing.radiusXs),
                ),
              ),
            ),
            Positioned(
              top: Spacing.xs,
              right: 36,
              child: Container(
                width: _sparkleSizeMd,
                height: _sparkleSizeMd,
                decoration: BoxDecoration(
                  color: color.tertiary,
                  borderRadius: BorderRadius.circular(Spacing.radiusXs),
                ),
              ),
            ),
            Positioned(
              top: Spacing.xl,
              right: 18,
              child: Container(
                width: _sparkleSizeSm,
                height: _sparkleSizeSm,
                decoration: BoxDecoration(
                  color: color.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

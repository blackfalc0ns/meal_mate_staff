import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverCallAvatar extends StatelessWidget {
  const DriverCallAvatar({super.key});

  static const double _outerSize = 190.0;
  static const double _midSize = 142.0;
  static const double _innerSize = 96.0;
  static const double _badgeSize = 34.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Center(
      child: SizedBox.square(
        dimension: _outerSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer concentric wave
            Container(
              width: _outerSize,
              height: _outerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.primary.withValues(alpha: 0.18),
                  width: Spacing.hairline * 3,
                ),
              ),
            ),

            // Middle concentric wave
            Container(
              width: _midSize,
              height: _midSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.primary.withValues(alpha: 0.32),
                  width: Spacing.hairline * 3,
                ),
              ),
            ),

            // Inner circle avatar
            Container(
              width: _innerSize,
              height: _innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.primary.withValues(alpha: 0.28),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 54,
                  color: color.primary,
                ),
              ),
            ),

            // Call indicator badge at bottom right
            PositionedDirectional(
              bottom: Spacing.xs,
              end: Spacing.xl + Spacing.xs,
              child: Container(
                width: _badgeSize,
                height: _badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.onPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: color.scrim.withValues(alpha: 0.25),
                      blurRadius: Spacing.radiusSm,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.phone_rounded,
                    size: Spacing.iconSm + 2,
                    color: color.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

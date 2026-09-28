import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverHomeMapCard extends StatelessWidget {
  const DriverHomeMapCard({
    super.key,
    this.onLocateTap,
  });

  final VoidCallback? onLocateTap;

  static const double _buttonSize = 34;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      height: Spacing.driverHomeMapHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.hairline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.driverMapPreview,
                fit: BoxFit.cover,
              ),
            ),
            PositionedDirectional(
              top: Spacing.md,
              start: Spacing.md,
              child: InkWell(
                onTap: onLocateTap,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: Container(
                  width: _buttonSize,
                  height: _buttonSize,
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: color.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: color.primary,
                    size: _iconSize,
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

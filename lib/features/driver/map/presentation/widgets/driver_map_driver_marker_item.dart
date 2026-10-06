import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import 'driver_map_pin_painter.dart';

class DriverMapDriverMarkerItem extends StatelessWidget {
  const DriverMapDriverMarkerItem({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    const pinWidth = Spacing.dispatcherMapMarkerAvatarSize;
    const pinHeight = Spacing.dispatcherMapMarkerAvatarSize + Spacing.md;

    return SizedBox(
      width: pinWidth,
      height: pinHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: const Size(pinWidth, pinHeight),
            painter: DriverMapPinPainter(
              primaryColor: color.primary,
              borderColor: color.surface,
              shadowColor: color.shadow,
            ),
          ),
          Positioned(
            top: Spacing.sm,
            child: Icon(
              Icons.person,
              color: color.onPrimary,
              size: Spacing.iconLg,
            ),
          ),
        ],
      ),
    );
  }
}

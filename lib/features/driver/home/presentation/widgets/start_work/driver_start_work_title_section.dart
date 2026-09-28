import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverStartWorkTitleSection extends StatelessWidget {
  const DriverStartWorkTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locale.driverStartWorkTitle,
          style: getBoldStyle(
            fontSize: FontSize.size18,
            color: color.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.driverStartWorkSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

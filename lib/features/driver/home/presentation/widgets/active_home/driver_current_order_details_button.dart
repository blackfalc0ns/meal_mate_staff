import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverCurrentOrderDetailsButton extends StatelessWidget {
  const DriverCurrentOrderDetailsButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  static const double _chevronSize = 10;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Spacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          border: Border.all(
            color: color.driverCardBorder,
            width: Spacing.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.driverViewDetailsAction,
              style: getRegularStyle(
                fontSize: FontSize.size11,
                color: color.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: _chevronSize,
              color: color.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

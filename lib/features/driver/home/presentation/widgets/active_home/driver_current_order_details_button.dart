import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverCurrentOrderDetailsButton extends StatelessWidget {
  const DriverCurrentOrderDetailsButton({super.key, this.onPressed});

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
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.driverViewDetailsAction,
              style: getMediumStyle(
                fontSize: FontSize.size11,
                color: color.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: _chevronSize,
              color: color.primary,
            ),
          ],
        ),
      ),
    );
  }
}

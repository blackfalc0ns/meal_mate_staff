import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverStartWorkActionButton extends StatelessWidget {
  const DriverStartWorkActionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  static const double _progressSize = 22;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SizedBox(
      width: double.infinity,
      height: Spacing.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.primary,
          foregroundColor: color.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.buttonRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: _progressSize,
                height: _progressSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color.onPrimary),
                ),
              )
            : Text(
                locale.driverStartWorkAction,
                style: getBoldStyle(
                  fontSize: FontSize.size16,
                  color: color.onPrimary,
                ),
              ),
      ),
    );
  }
}

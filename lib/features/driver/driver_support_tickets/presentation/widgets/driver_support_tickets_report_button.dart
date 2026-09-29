import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportTicketsReportButton extends StatelessWidget {
  const DriverSupportTicketsReportButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SizedBox(
      width: double.infinity,
      height: Spacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.primary,
          foregroundColor: color.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.buttonRadius),
          ),
          elevation: Spacing.cardElevation,
        ),
        icon: Icon(
          Icons.add_rounded,
          size: Spacing.iconMd,
          color: color.onPrimary,
        ),
        label: Text(
          locale.driverSupportTicketsReportNewIssue,
          style: getSemiBoldStyle(
            fontSize: FontSize.size14,
            color: color.onPrimary,
          ),
        ),
      ),
    );
  }
}

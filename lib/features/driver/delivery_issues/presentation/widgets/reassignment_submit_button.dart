import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class ReassignmentSubmitButton extends StatelessWidget {
  const ReassignmentSubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

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
          disabledBackgroundColor: color.primary.withValues(alpha: 0.35),
          disabledForegroundColor: color.onPrimary.withValues(alpha: 0.7),
          elevation: onPressed != null ? Spacing.cardElevation : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color.onPrimary,
                  ),
                ),
              )
            : Text(
                locale.reassignRequestSubmit,
                style: getBoldStyle(
                  fontSize: FontSize.size16,
                  color: color.onPrimary,
                ),
              ),
      ),
    );
  }
}

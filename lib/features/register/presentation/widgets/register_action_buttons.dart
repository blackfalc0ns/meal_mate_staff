import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterActionButtons extends StatelessWidget {
  const RegisterActionButtons({
    super.key,
    required this.onSubmit,
    required this.onBackToEdit,
  });

  final VoidCallback onSubmit;
  final VoidCallback onBackToEdit;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Spacing.registrationButtonHeight,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.registrationRadius),
              ),
              textStyle: getBoldStyle(
                color: color.onPrimary,
                fontSize: FontSize.size13,
              ),
            ),
            child: Text(locale.registrationSubmitRequest),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: Spacing.registrationButtonHeight,
          child: OutlinedButton(
            onPressed: onBackToEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: color.primary,
              side: BorderSide(color: color.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.registrationRadius),
              ),
              textStyle: getBoldStyle(
                color: color.primary,
                fontSize: FontSize.size13,
              ),
            ),
            child: Text(locale.registrationBackToEdit),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';

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
        AppButton(
          text: locale.registrationSubmitRequest,
          onPressed: onSubmit,
          height: Spacing.xxl,
          borderRadius: Spacing.registrationRadius,
          color: color.primary,
          textColor: color.onPrimary,
          textStyle: getBoldStyle(
            color: color.onPrimary,
            fontSize: FontSize.size10,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        AppButton(
          text: locale.registrationBackToEdit,
          onPressed: onBackToEdit,
          variant: AppButtonVariant.outlined,
          height: Spacing.xxl,
          borderRadius: Spacing.registrationRadius,
          color: color.primary,
          textColor: color.primary,
          textStyle: getBoldStyle(
            color: color.primary,
            fontSize: FontSize.size10,
          ),
        ),
      ],
    );
  }
}

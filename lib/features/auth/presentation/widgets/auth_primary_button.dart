import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return AppButton(
      text: text,
      onPressed: onPressed,
      height: 42,
      borderRadius: Spacing.radiusPill,
      color: color.primary,
      textColor: color.onPrimary,
      textStyle: getSemiBoldStyle(
        color: color.onPrimary,
        fontSize: FontSize.size13,
      ),
    );
  }
}

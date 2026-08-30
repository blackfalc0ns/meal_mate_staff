import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.leadingIcon,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SizedBox(
      height: 42,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(leadingIcon, size: Spacing.iconSm, color: color.primary),
        label: Text(
          text,
          style: getSemiBoldStyle(
            color: color.primary,
            fontSize: FontSize.size12,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: color.surface,
          foregroundColor: color.primary,
          side: BorderSide(color: color.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
          ),
        ),
      ),
    );
  }
}

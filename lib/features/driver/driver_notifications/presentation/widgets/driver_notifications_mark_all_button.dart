import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DriverNotificationsMarkAllButton extends StatelessWidget {
  const DriverNotificationsMarkAllButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return AppButton(
      text: locale.driverNotificationsMarkAllRead,
      icon: Icons.check_circle_outline_rounded,
      onPressed: onPressed,
      color: color.primary,
      textColor: color.onPrimary,
      height: Spacing.buttonHeight,
      borderRadius: Spacing.buttonRadius,
    );
  }
}

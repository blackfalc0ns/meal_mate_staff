import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DriverBoxesReceivedActionButton extends StatelessWidget {
  const DriverBoxesReceivedActionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return AppButton(
      text: locale.driverStartDeliveryButton,
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      isLoading: isLoading,
      color: isEnabled
          ? color.primary
          : color.outlineVariant.withValues(alpha: 0.3),
      textColor: isEnabled
          ? color.onPrimary
          : color.onSurfaceVariant.withValues(alpha: 0.5),
      height: Spacing.buttonHeight,
      borderRadius: Spacing.buttonRadius,
      icon: Icons.arrow_forward_rounded,
    );
  }
}

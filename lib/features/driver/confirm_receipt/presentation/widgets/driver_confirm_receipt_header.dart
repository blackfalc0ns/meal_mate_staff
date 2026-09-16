import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_back_button.dart';
import '../../../orders/presentation/widgets/driver_boxes_header_logo.dart';
import 'driver_receipt_stepper_bar.dart';

class DriverConfirmReceiptHeader extends StatelessWidget {
  const DriverConfirmReceiptHeader({
    super.key,
    required this.currentStep,
    this.onBack,
  });

  final int currentStep;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomBackButton(onPressed: onBack),
            const DriverBoxesHeaderLogo(),
            const SizedBox(width: Spacing.iconLg + Spacing.sm),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          locale.driverConfirmReceiptTitle,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.md),
        DriverReceiptStepperBar(currentStep: currentStep),
      ],
    );
  }
}

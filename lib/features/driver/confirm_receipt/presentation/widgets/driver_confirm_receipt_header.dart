import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
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
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomAppBar.logo(
          title: locale.driverConfirmReceiptTitle,
          onBackPressed: onBack,
        ),
        const SizedBox(height: Spacing.md),
        DriverReceiptStepperBar(currentStep: currentStep),
      ],
    );
  }
}

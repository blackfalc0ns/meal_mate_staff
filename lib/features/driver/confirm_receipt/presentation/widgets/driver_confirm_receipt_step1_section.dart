import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import 'driver_manual_code_button.dart';
import 'driver_qr_header_section.dart';
import 'driver_qr_viewfinder.dart';
import 'driver_step2_preview_card.dart';

class DriverConfirmReceiptStep1Section extends StatelessWidget {
  const DriverConfirmReceiptStep1Section({
    super.key,
    required this.scannerController,
    required this.isFlashOn,
    required this.onFlashChanged,
    required this.onScanSuccess,
    required this.onEnterCodeManually,
    required this.isQrScanned,
    required this.onContinueToStep2,
  });

  final MobileScannerController scannerController;
  final bool isFlashOn;
  final ValueChanged<bool> onFlashChanged;
  final VoidCallback onScanSuccess;
  final VoidCallback onEnterCodeManually;
  final bool isQrScanned;
  final VoidCallback onContinueToStep2;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DriverQrHeaderSection(
          isFlashOn: isFlashOn,
          onFlashChanged: onFlashChanged,
        ),
        const SizedBox(height: Spacing.md),
        DriverQrViewfinder(
          controller: scannerController,
          onScanSuccess: onScanSuccess,
        ),
        const SizedBox(height: Spacing.md),
        DriverManualCodeButton(onPressed: onEnterCodeManually),
        const SizedBox(height: Spacing.md),
        DriverStep2PreviewCard(isUnlocked: isQrScanned),
        const SizedBox(height: Spacing.lg),
        AppButton(
          text: locale.driverContinueToPhotographBox,
          onPressed: isQrScanned ? onContinueToStep2 : null,
          variant: AppButtonVariant.filled,
          isExpanded: true,
          height: Spacing.buttonHeight,
          borderRadius: Spacing.radiusMd,
          color: isQrScanned
              ? color.primary
              : color.outlineVariant.withValues(alpha: 0.3),
          textColor: isQrScanned
              ? color.onPrimary
              : color.onSurfaceVariant.withValues(alpha: 0.4),
          icon: Icons.arrow_forward_rounded,
          iconSize: Spacing.iconSm,
          textStyle: getBoldStyle(
            color: isQrScanned
                ? color.onPrimary
                : color.onSurfaceVariant.withValues(alpha: 0.4),
            fontSize: FontSize.size14,
          ),
        ),
      ],
    );
  }
}

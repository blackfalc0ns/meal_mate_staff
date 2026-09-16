import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import 'driver_camera_viewfinder.dart';

class DriverConfirmReceiptStep2Section extends StatelessWidget {
  const DriverConfirmReceiptStep2Section({
    super.key,
    this.scannerController,
    required this.isPhotoCaptured,
    required this.onCapturePhoto,
    required this.onConfirmDelivery,
    this.capturedPhotoPath,
  });

  final MobileScannerController? scannerController;
  final bool isPhotoCaptured;
  final VoidCallback onCapturePhoto;
  final VoidCallback onConfirmDelivery;
  final String? capturedPhotoPath;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.driverPhotographBoxTitle,
              style: getBoldStyle(
                color: color.onSurface,
                fontSize: FontSize.size18,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: Spacing.hairline * 4),
            Text(
              locale.driverPhotographBoxSubtitle,
              style: getRegularStyle(
                color: color.onSurfaceVariant,
                fontSize: FontSize.size11,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        DriverCameraViewfinder(
          controller: scannerController,
          isPhotoCaptured: isPhotoCaptured,
          onCapturePhoto: onCapturePhoto,
          capturedPhotoPath: capturedPhotoPath,
        ),
        const SizedBox(height: Spacing.xl),
        AppButton(
          text: isPhotoCaptured
              ? locale.driverConfirmDeliveryAction
              : locale.driverTakePhotoAction,
          onPressed: isPhotoCaptured ? onConfirmDelivery : onCapturePhoto,
          variant: AppButtonVariant.filled,
          isExpanded: true,
          height: Spacing.buttonHeight,
          borderRadius: Spacing.radiusMd,
          color: color.primary,
          textColor: color.onPrimary,
          icon: isPhotoCaptured
              ? Icons.check_circle_rounded
              : Icons.camera_alt_rounded,
          iconSize: Spacing.iconSm,
          textStyle: getBoldStyle(
            color: color.onPrimary,
            fontSize: FontSize.size14,
          ),
        ),
      ],
    );
  }
}

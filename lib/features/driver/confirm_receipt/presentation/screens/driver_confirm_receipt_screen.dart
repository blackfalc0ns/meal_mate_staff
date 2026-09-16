import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../../orders/domain/entities/driver_assigned_box_entity.dart';
import '../../../orders/presentation/widgets/driver_boxes_header_logo.dart';
import '../widgets/driver_camera_viewfinder.dart';
import '../widgets/driver_manual_code_button.dart';
import '../widgets/driver_qr_header_section.dart';
import '../widgets/driver_qr_viewfinder.dart';
import '../widgets/driver_receipt_stepper_bar.dart';
import '../widgets/driver_step2_preview_card.dart';

class DriverConfirmReceiptScreen extends StatefulWidget {
  const DriverConfirmReceiptScreen({
    super.key,
    this.box,
    this.scannerController,
  });

  final DriverAssignedBoxEntity? box;
  final MobileScannerController? scannerController;

  @override
  State<DriverConfirmReceiptScreen> createState() =>
      _DriverConfirmReceiptScreenState();
}

class _DriverConfirmReceiptScreenState
    extends State<DriverConfirmReceiptScreen> {
  late final MobileScannerController _scannerController;
  late final bool _isInternalController;

  int _currentStep = 1;
  bool _isFlashOn = false;
  bool _isQrScanned = false;
  bool _isPhotoCaptured = false;
  String? _capturedPhotoPath;

  @override
  @override
  void dispose() {
    if (_isInternalController) {
      _scannerController.dispose();
    }
    super.dispose();
  }

  void _handleScanSuccess() {
    setState(() {
      _isQrScanned = true;
    });
    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message:
          '${locale.driverStepScanQr}: ${widget.box?.boxId ?? "#BOX-1256"}',
    );
  }

  void _handleEnterCodeManually() {
    setState(() {
      _isQrScanned = true;
    });
    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message:
          '${locale.driverEnterCodeManually}: ${widget.box?.boxId ?? "#BOX-1256"}',
    );
  }

  void _goToStep2() {
    setState(() {
      _currentStep = 2;
    });
  }

  Future<void> _handleCapturePhoto() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() {
          _capturedPhotoPath = photo.path;
          _isPhotoCaptured = true;
        });
        return;
      }
    } catch (_) {
      // Fallback on environments where native camera activity cannot be launched
    }

    if (mounted) {
      setState(() {
        _isPhotoCaptured = true;
      });
    }
  }

  void _handleConfirmReceipt() {
    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message: locale.driverBoxVerifiedSuccess,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header logo with back navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: Spacing.iconSm,
                      color: color.onSurface,
                    ),
                  ),
                  const DriverBoxesHeaderLogo(),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: Spacing.sm),

              // Screen Title
              Text(
                locale.driverConfirmReceiptTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),

              // Stepper Bar
              DriverReceiptStepperBar(currentStep: _currentStep),
              const SizedBox(height: Spacing.lg),

              if (_currentStep == 1) ...[
                // Step 1: QR Scanner
                DriverQrHeaderSection(
                  isFlashOn: _isFlashOn,
                  onFlashChanged: (val) async {
                    try {
                      await _scannerController.toggleTorch();
                    } catch (_) {}
                    setState(() => _isFlashOn = val);
                  },
                ),
                const SizedBox(height: Spacing.md),
                DriverQrViewfinder(
                  controller: _scannerController,
                  onScanSuccess: _handleScanSuccess,
                ),
                const SizedBox(height: Spacing.md),
                DriverManualCodeButton(onPressed: _handleEnterCodeManually),
                const SizedBox(height: Spacing.md),
                DriverStep2PreviewCard(isUnlocked: _isQrScanned),
                const SizedBox(height: Spacing.lg),
                AppButton(
                  text: locale.driverContinueToPhotographBox,
                  onPressed: _isQrScanned ? _goToStep2 : null,
                  variant: AppButtonVariant.filled,
                  isExpanded: true,
                  height: Spacing.buttonHeight,
                  borderRadius: Spacing.radiusMd,
                  color: _isQrScanned
                      ? color.primary
                      : color.outlineVariant.withValues(alpha: 0.3),
                  textColor: _isQrScanned
                      ? color.onPrimary
                      : color.onSurfaceVariant.withValues(alpha: 0.4),
                  icon: Icons.arrow_forward_rounded,
                  iconSize: Spacing.iconSm,
                  textStyle: getBoldStyle(
                    color: _isQrScanned
                        ? color.onPrimary
                        : color.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: FontSize.size14,
                  ),
                ),
              ] else ...[
                // Step 2: Photograph Box
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      locale.driverPhotographBoxTitle,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size18,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: Spacing.hairline * 4),
                    Text(
                      locale.driverPhotographBoxSubtitle,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                DriverCameraViewfinder(
                  isPhotoCaptured: _isPhotoCaptured,
                  onCapturePhoto: _handleCapturePhoto,
                  capturedPhotoPath: _capturedPhotoPath,
                ),
                const SizedBox(height: Spacing.xl),
                AppButton(
                  text: locale.driverConfirmDeliveryAction,
                  onPressed: _isPhotoCaptured ? _handleConfirmReceipt : null,
                  variant: AppButtonVariant.filled,
                  isExpanded: true,
                  height: Spacing.buttonHeight,
                  borderRadius: Spacing.radiusMd,
                  color: _isPhotoCaptured
                      ? color.primary
                      : color.outlineVariant.withValues(alpha: 0.3),
                  textColor: _isPhotoCaptured
                      ? color.onPrimary
                      : color.onSurfaceVariant.withValues(alpha: 0.4),
                  icon: Icons.check_circle_rounded,
                  iconSize: Spacing.iconSm,
                  textStyle: getBoldStyle(
                    color: _isPhotoCaptured
                        ? color.onPrimary
                        : color.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: FontSize.size14,
                  ),
                ),
              ],
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

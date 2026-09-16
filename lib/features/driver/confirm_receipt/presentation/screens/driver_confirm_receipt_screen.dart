import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../../orders/domain/entities/driver_assigned_box_entity.dart';
import '../widgets/driver_confirm_receipt_header.dart';
import '../widgets/driver_confirm_receipt_step1_section.dart';
import '../widgets/driver_confirm_receipt_step2_section.dart';
import '../widgets/driver_manual_code_modal_sheet.dart';

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
  void initState() {
    super.initState();
    if (widget.scannerController != null) {
      _scannerController = widget.scannerController!;
      _isInternalController = false;
    } else {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        autoStart: true,
      );
      _isInternalController = true;
    }
  }

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
    DriverManualCodeModalSheet.show(
      context: context,
      defaultCode: widget.box?.boxId ?? '#BOX-1256',
      onCodeSubmitted: (code) {
        setState(() {
          _isQrScanned = true;
        });
        final locale = context.localization;
        CustomSnackbar.showSuccess(
          context: context,
          message: '${locale.driverEnterCodeManually}: $code',
        );
      },
    );
  }

  void _goToStep2() {
    setState(() {
      _currentStep = 2;
    });
  }

  Future<void> _handleCapturePhoto() async {
    if (_isPhotoCaptured) {
      try {
        await _scannerController.start();
      } catch (_) {}
      setState(() {
        _isPhotoCaptured = false;
        _capturedPhotoPath = null;
      });
      return;
    }

    try {
      await _scannerController.pause();
    } catch (_) {}

    setState(() {
      _isPhotoCaptured = true;
    });
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
              DriverConfirmReceiptHeader(currentStep: _currentStep),
              const SizedBox(height: Spacing.lg),
              if (_currentStep == 1)
                DriverConfirmReceiptStep1Section(
                  scannerController: _scannerController,
                  isFlashOn: _isFlashOn,
                  onFlashChanged: (val) async {
                    try {
                      await _scannerController.toggleTorch();
                    } catch (_) {}
                    setState(() => _isFlashOn = val);
                  },
                  onScanSuccess: _handleScanSuccess,
                  onEnterCodeManually: _handleEnterCodeManually,
                  isQrScanned: _isQrScanned,
                  onContinueToStep2: _goToStep2,
                )
              else
                DriverConfirmReceiptStep2Section(
                  scannerController: _scannerController,
                  isPhotoCaptured: _isPhotoCaptured,
                  onCapturePhoto: _handleCapturePhoto,
                  onConfirmDelivery: _handleConfirmReceipt,
                  capturedPhotoPath: _capturedPhotoPath,
                ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

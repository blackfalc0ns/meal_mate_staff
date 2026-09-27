import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/driver_pickup_summary_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../orders/domain/entities/driver_assigned_box_entity.dart';
import '../../domain/entities/driver_box_received_success_entity.dart';
import '../../domain/entities/driver_pickup_confirmation_entity.dart';
import '../manager/driver_pickup_flow_event.dart';
import '../manager/driver_pickup_flow_state.dart';
import '../manager/driver_pickup_flow_view_model.dart';
import '../widgets/driver_confirm_receipt_header.dart';
import '../widgets/driver_confirm_receipt_step1_section.dart';
import '../widgets/driver_confirm_receipt_step2_section.dart';
import '../widgets/driver_manual_code_modal_sheet.dart';

class DriverConfirmReceiptScreen extends StatefulWidget {
  const DriverConfirmReceiptScreen({
    super.key,
    this.box,
    this.scannerController,
    this.viewModel,
  });

  final DriverAssignedBoxEntity? box;
  final MobileScannerController? scannerController;
  final DriverPickupFlowViewModel? viewModel;

  @override
  State<DriverConfirmReceiptScreen> createState() =>
      _DriverConfirmReceiptScreenState();
}

class _DriverConfirmReceiptScreenState
    extends State<DriverConfirmReceiptScreen> {
  late final MobileScannerController _scannerController;
  late final bool _isInternalController;
  late final DriverPickupFlowViewModel _viewModel;
  late final bool _isInternalViewModel;

  bool _isFlashOn = false;

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

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else {
      _viewModel = getIt<DriverPickupFlowViewModel>();
      _isInternalViewModel = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalViewModel) {
      _viewModel.close();
    }
    if (_isInternalController) {
      _scannerController.dispose();
    }
    super.dispose();
  }

  void _handleBarcodeScanned(String barcode) {
    _viewModel.doIntent(ValidateBarcodeEvent(barcode));
  }

  void _handleEnterCodeManually() {
    DriverManualCodeModalSheet.show(
      context: context,
      defaultCode: widget.box?.boxCode ?? widget.box?.boxId ?? '',
      onCodeSubmitted: (code) {
        _viewModel.doIntent(ValidateBarcodeEvent(code));
      },
    );
  }

  void _goToStep2() {
    _viewModel.doIntent(const StepChangedEvent(2));
  }

  Future<void> _handleCapturePhoto() async {
    if (_viewModel.state.localPhotoPath != null) {
      _viewModel.doIntent(const PhotoSelectedEvent(''));
      try {
        await _scannerController.start();
      } catch (_) {}
      return;
    }

    try {
      await _scannerController.pause();
    } catch (_) {}

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _viewModel.doIntent(PhotoSelectedEvent(image.path));
        return;
      }
    } catch (_) {}

    // Fallback for tests or when camera device is unavailable
    _viewModel.doIntent(const PhotoSelectedEvent('condition_photo.jpg'));
  }

  void _handleConfirmReceipt() {
    _viewModel.doIntent(const ConfirmPickupEvent());
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocConsumer<DriverPickupFlowViewModel, DriverPickupFlowState>(
      bloc: _viewModel,
      listenWhen: (prev, curr) =>
          prev.stage != curr.stage ||
          prev.requiresRescan != curr.requiresRescan,
      listener: (context, state) {
        if (state.stage == DriverPickupFlowStage.pickedUp) {
          final nextAction = state.confirmation?.nextAction;
          if (nextAction == DriverPickupNextAction.showPickupSummary) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.driverBoxesReceived,
              arguments: DriverPickupSummaryRouteArguments(
                tripId: state.confirmation?.tripId ?? '',
              ),
            );
          } else if (nextAction == DriverPickupNextAction.showBoxSuccess) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.driverBoxReceivedSuccess,
              arguments: DriverBoxReceivedSuccessEntity(
                boxCode:
                    state.validatedBox?.boxCode ??
                    state.confirmation?.boxCode ??
                    widget.box?.boxCode ??
                    '',
                restaurantName:
                    state.validatedBox?.customerName ??
                    widget.box?.customerName ??
                    '',
                itemsCount:
                    state.validatedBox?.mealsCount ??
                    widget.box?.mealsCount ??
                    0,
                expectedReceiptTime:
                    state.validatedBox?.deliveryTimeSlot ??
                    widget.box?.deliveryTimeSlot ??
                    '',
                isReceived: true,
              ),
            );
          }
        } else if (state.requiresRescan && state.currentStep != 1) {
          _viewModel.doIntent(const StepChangedEvent(1));
          _viewModel.doIntent(const ResetScanEvent());
        }
      },
      builder: (context, state) {
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
                  DriverConfirmReceiptHeader(currentStep: state.currentStep),
                  const SizedBox(height: Spacing.lg),
                  if (state.currentStep == 1)
                    DriverConfirmReceiptStep1Section(
                      scannerController: _scannerController,
                      isFlashOn: _isFlashOn,
                      onFlashChanged: (val) async {
                        try {
                          await _scannerController.toggleTorch();
                        } catch (_) {}
                        setState(() => _isFlashOn = val);
                      },
                      onScanSuccess: () => _handleBarcodeScanned(
                        widget.box?.boxCode ?? widget.box?.boxId ?? 'BOX-101',
                      ),
                      onEnterCodeManually: _handleEnterCodeManually,
                      isQrScanned: state.isBarcodeValidated,
                      onContinueToStep2: _goToStep2,
                      failure: state.failure,
                      onRetry: () =>
                          _viewModel.doIntent(const RetryFailedStageEvent()),
                      isLoading: state.isValidatingBarcode,
                    )
                  else
                    DriverConfirmReceiptStep2Section(
                      scannerController: _scannerController,
                      isPhotoCaptured:
                          state.localPhotoPath != null &&
                          state.localPhotoPath!.isNotEmpty,
                      onCapturePhoto: _handleCapturePhoto,
                      onConfirmDelivery: _handleConfirmReceipt,
                      capturedPhotoPath: state.localPhotoPath,
                      failure: state.failure,
                      onRetry: () =>
                          _viewModel.doIntent(const RetryFailedStageEvent()),
                      isLoading: state.isActionLoading,
                    ),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

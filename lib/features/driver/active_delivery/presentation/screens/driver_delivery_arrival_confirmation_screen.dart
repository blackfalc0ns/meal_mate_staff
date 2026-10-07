import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/driver_active_delivery_route_arguments.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../manager/active_delivery_event.dart';
import '../manager/active_delivery_state.dart';
import '../manager/active_delivery_view_model.dart';
import '../services/driver_delivery_proof_camera.dart';
import '../widgets/driver_active_delivery_shimmer.dart';
import '../widgets/driver_delivery_arrival_banner.dart';
import '../widgets/driver_delivery_customer_details_card.dart';
import '../widgets/driver_delivery_optional_otp_section.dart';
import '../widgets/driver_delivery_proof_photo_section.dart';

class DriverDeliveryArrivalConfirmationScreen extends StatefulWidget {
  const DriverDeliveryArrivalConfirmationScreen({
    super.key,
    this.arguments,
    this.viewModel,
    this.cameraService,
    this.onDeliveryConfirmed,
  });

  final DriverActiveDeliveryRouteArguments? arguments;
  final ActiveDeliveryViewModel? viewModel;
  final DriverDeliveryProofCameraService? cameraService;
  final VoidCallback? onDeliveryConfirmed;

  @override
  State<DriverDeliveryArrivalConfirmationScreen> createState() =>
      _DriverDeliveryArrivalConfirmationScreenState();
}

class _DriverDeliveryArrivalConfirmationScreenState
    extends State<DriverDeliveryArrivalConfirmationScreen> {
  late final ActiveDeliveryViewModel? _viewModel;
  late final DriverDeliveryProofCameraService _cameraService;
  int _lastHandledNavRevision = 0;

  @override
  void initState() {
    super.initState();
    _cameraService = widget.cameraService ??
        const DriverDeliveryProofCameraServiceImpl();

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
    } else if (getIt.isRegistered<ActiveDeliveryViewModel>()) {
      _viewModel = getIt<ActiveDeliveryViewModel>();
    } else {
      _viewModel = null;
    }

    if (_viewModel != null) {
      _lastHandledNavRevision = _viewModel.state.navigationRevision;
      if (_viewModel.state.route == null) {
        _viewModel.doIntent(
          LoadActiveDeliveryEvent(stopId: widget.arguments?.stopId),
        );
      }
    }
  }

  Future<void> _handlePickPhoto() async {
    final path = await _cameraService.captureProofPhoto();
    if (path != null && mounted) {
      _viewModel?.doIntent(
        DeliveryProofSelectedEvent(path),
      );
    }
  }

  void _handleRetryUpload() {
    _viewModel?.doIntent(const RetryDeliveryProofUploadEvent());
  }

  void _handleOtpChanged(String otp) {
    _viewModel?.doIntent(OptionalDeliveryOtpChangedEvent(otp));
  }

  void _handleConfirmDelivery() {
    _viewModel?.doIntent(const ConfirmCustomerDeliveryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final color = context.colorScheme;
    final pageTitle = isAr ? 'تأكيد التسليم للعميل' : 'Delivery Confirmation';

    if (_viewModel == null) {
      return Scaffold(
        appBar: CustomAppBar.simple(title: pageTitle, showBackButton: true),
        body: Center(
          child: Text(
            isAr ? 'لم يتم العثور على بيانات الرحلة' : 'No trip data found',
            style: TextStyle(color: color.onSurface),
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<ActiveDeliveryViewModel, ActiveDeliveryState>(
        listener: (context, state) {
          if (state.deliveryResult != null &&
              state.navigationRevision > _lastHandledNavRevision) {
            _lastHandledNavRevision = state.navigationRevision;
            if (widget.onDeliveryConfirmed != null) {
              widget.onDeliveryConfirmed!();
              return;
            }
            final stop = state.selectedStop;
            unawaited(
              context.pushReplacementNamed(
                AppRoutes.driverDeliverySuccess,
                arguments: DriverActiveDeliveryRouteArguments(
                  stopId: stop?.id ?? widget.arguments?.stopId,
                  tripId: state.route?.tripId ?? widget.arguments?.tripId,
                  deliveryResult: state.deliveryResult,
                  completedStop: stop,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isInitialLoading && state.route == null) {
            return Scaffold(
              appBar: CustomAppBar.simple(title: pageTitle, showBackButton: true),
              body: const SafeArea(
                bottom: false,
                child: DriverActiveDeliveryShimmer(),
              ),
            );
          }

          final stop = state.selectedStop;
          if (stop == null) {
            return Scaffold(
              appBar: CustomAppBar.simple(title: pageTitle, showBackButton: true),
              body: Center(
                child: Text(
                  isAr ? 'لا توجد محطة توصيل محددة' : 'No active delivery stop',
                  style: TextStyle(color: color.onSurface),
                ),
              ),
            );
          }

          final canSubmit = state.canDeliver;
          final isDelivering = state.isDelivering;

          return Scaffold(
            appBar: CustomAppBar.simple(title: pageTitle, showBackButton: true),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.base,
                  Spacing.xs,
                  Spacing.base,
                  Spacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!state.isProofUploaded) ...[
                      Text(
                        isAr
                            ? '* يلزم التقاط ورفع صورة إثبات التسليم لتأكيد التسليم'
                            : '* Delivery proof photo must be uploaded to confirm delivery',
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.xs),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: Spacing.buttonHeight,
                      child: ElevatedButton(
                        key: const ValueKey('confirm_delivery_submit_button'),
                        onPressed: canSubmit && !isDelivering
                            ? _handleConfirmDelivery
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.primary,
                          foregroundColor: color.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Spacing.cardRadius),
                          ),
                          elevation: 0,
                        ),
                        child: isDelivering
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color.onPrimary,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isAr
                                        ? 'تأكيد تسليم الطلب'
                                        : 'Confirm Delivery',
                                    style: getBoldStyle(
                                      fontSize: FontSize.size15,
                                      color: color.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.sm),
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: Spacing.iconSm,
                                    color: color.onPrimary,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base,
                  vertical: Spacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.xs),
                    DriverDeliveryArrivalBanner(
                      title: isAr
                          ? 'تم تأكيد الوصول لموقع العميل'
                          : 'Arrived at Customer Location',
                      subtitle: isAr
                          ? 'يرجى تسليم الصندوق والتقاط صورة الإثبات'
                          : 'Please hand over the box and capture proof photo',
                    ),
                    const SizedBox(height: Spacing.md),
                    DriverDeliveryCustomerDetailsCard(stop: stop),
                    const SizedBox(height: Spacing.md),
                    DriverDeliveryProofPhotoSection(
                      localPhotoPath: state.localPhotoPath,
                      isUploading: state.isUploading,
                      isUploaded: state.isProofUploaded,
                      errorMessage: state.uploadFailure?.errorMessage,
                      onPickPhoto: _handlePickPhoto,
                      onRetryUpload: _handleRetryUpload,
                    ),
                    const SizedBox(height: Spacing.md),
                    DriverDeliveryOptionalOtpSection(
                      initialOtp: state.otpInput,
                      onOtpChanged: _handleOtpChanged,
                    ),
                    const SizedBox(height: Spacing.base),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

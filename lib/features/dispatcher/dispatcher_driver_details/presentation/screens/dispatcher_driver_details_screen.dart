import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/box_tracking_route_arguments.dart';
import '../../../../../config/routing/arguments/dispatcher_map_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/driver_active_box_entity.dart';
import '../manager/driver_details_event.dart';
import '../manager/driver_details_state.dart';
import '../manager/driver_details_view_model.dart';
import '../services/driver_contact_launcher.dart';
import '../widgets/driver_details_action_buttons.dart';
import '../widgets/driver_details_app_bar.dart';
import '../widgets/driver_details_boxes_card.dart';
import '../widgets/driver_details_boxes_shimmer.dart';
import '../widgets/driver_details_kpi_row.dart';
import '../widgets/driver_details_location_card.dart';
import '../widgets/driver_details_location_shimmer.dart';
import '../widgets/driver_details_performance_card.dart';
import '../widgets/driver_details_profile_card.dart';
import '../widgets/driver_details_shimmer.dart';

class DispatcherDriverDetailsScreen extends StatefulWidget {
  const DispatcherDriverDetailsScreen({
    super.key,
    required this.driverId,
    this.viewModel,
    this.contactLauncher,
    this.onBack,
    this.onMore,
    this.onOpenMap,
    this.onSelectBox,
    this.onNavItemSelected,
  });

  final String driverId;
  final DriverDetailsViewModel? viewModel;
  final DriverContactLauncher? contactLauncher;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final VoidCallback? onOpenMap;
  final ValueChanged<DriverActiveBoxEntity>? onSelectBox;
  final ValueChanged<int>? onNavItemSelected;

  @override
  State<DispatcherDriverDetailsScreen> createState() =>
      _DispatcherDriverDetailsScreenState();
}

class _DispatcherDriverDetailsScreenState
    extends State<DispatcherDriverDetailsScreen>
    with WidgetsBindingObserver {
  late final DriverDetailsViewModel _viewModel;
  late final DriverContactLauncher _contactLauncher;
  bool _ownsViewModel = false;
  int? _lastNoticeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
    } else {
      _viewModel = getIt<DriverDetailsViewModel>(param1: widget.driverId);
      _ownsViewModel = true;
    }

    _contactLauncher = widget.contactLauncher ??
        (getIt.isRegistered<DriverContactLauncher>()
            ? getIt<DriverContactLauncher>()
            : const DriverContactLauncherImpl());

    _viewModel.doIntent(const LoadDriverDetailsEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.doIntent(const DriverDetailsLifecycleResumed());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _viewModel.doIntent(const DriverDetailsLifecyclePaused());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  Future<void> _handleCall(String phoneNumber) async {
    final success = await _contactLauncher.launchPhone(phoneNumber);
    if (!success && mounted) {
      CustomSnackbar.showError(
        context: context,
        message: context.localization.driverDetailsUnableToCall,
      );
    }
  }

  Future<void> _handleSms(String phoneNumber) async {
    final success = await _contactLauncher.launchSms(phoneNumber);
    if (!success && mounted) {
      CustomSnackbar.showError(
        context: context,
        message: context.localization.driverDetailsUnableToSms,
      );
    }
  }

  Future<void> _handleWhatsApp(String phoneNumber) async {
    final success = await _contactLauncher.launchWhatsApp(phoneNumber);
    if (!success && mounted) {
      CustomSnackbar.showError(
        context: context,
        message: context.localization.driverDetailsUnableToWhatsApp,
      );
    }
  }

  void _handleBoxTap(DriverActiveBoxEntity box) {
    if (widget.onSelectBox != null) {
      widget.onSelectBox!(box);
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.boxTracking,
      arguments: BoxTrackingRouteArguments(boxId: box.boxId),
    );
  }

  void _handleOpenOnMap() {
    if (widget.onOpenMap != null) {
      widget.onOpenMap!();
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.dispatcherMap,
      arguments: DispatcherMapRouteArgs(focusDriverId: widget.driverId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocConsumer<DriverDetailsViewModel, DriverDetailsState>(
      bloc: _viewModel,
      listenWhen: (previous, current) =>
          current.noticeId != null && current.noticeId != _lastNoticeId,
      listener: (context, state) {
        _lastNoticeId = state.noticeId;
        if (state.noticeFailure != null) {
          CustomSnackbar.showError(
            context: context,
            message: state.noticeFailure!.errorMessage,
          );
        }
      },
      builder: (context, state) {
        // Initial Full-Screen Shimmer when profile is loading
        if (state.isProfileLoading && state.details == null) {
          return Scaffold(
            appBar: DriverDetailsAppBar(
              onBack: widget.onBack,
              onMore: widget.onMore,
            ),
            body: const SafeArea(
              bottom: false,
              child: DriverDetailsShimmer(),
            ),
          );
        }

        // Full Screen Profile Failure
        if (state.details == null && state.profileFailure != null) {
          return Scaffold(
            appBar: DriverDetailsAppBar(
              onBack: widget.onBack,
              onMore: widget.onMore,
            ),
            body: SafeArea(
              child: Center(
                child: ApiErrorWidget.fromTypedFailure(
                  failure: state.profileFailure!,
                  onRetry: () =>
                      _viewModel.doIntent(const RetryDriverProfileEvent()),
                ),
              ),
            ),
          );
        }

        final details = state.details!;
        final driverProfile = details.driver;
        final kpis = details.kpis;
        final dailySummary = details.dailySummary;
        final phoneNumber = driverProfile.phoneNumber;
        final hasValidPhone =
            phoneNumber != null && phoneNumber.trim().isNotEmpty;

        return Scaffold(
          appBar: DriverDetailsAppBar(
            onBack: widget.onBack,
            onMore: widget.onMore,
          ),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                final completer = Completer<void>();
                _viewModel.doIntent(const RefreshDriverDetailsEvent());
                // Short delay to let the state machine process refresh
                await Future<void>.delayed(const Duration(milliseconds: 300));
                completer.complete();
                return completer.future;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.xs),
                    DriverDetailsProfileCard(profile: driverProfile),
                    const SizedBox(height: Spacing.xs),
                    DriverDetailsKpiRow(kpis: kpis),
                    const SizedBox(height: Spacing.sm),
                    // Current Location Section
                    if (state.isLocationLoading && state.location == null)
                      const DriverDetailsLocationShimmer()
                    else if (state.locationFailure != null &&
                        state.location == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.base,
                          vertical: Spacing.xs,
                        ),
                        child: InlineApiErrorWidget(
                          failure: state.locationFailure!,
                          onRetry: () =>
                              _viewModel.doIntent(const RetryDriverLocationEvent()),
                        ),
                      )
                    else if (state.location != null)
                      DriverDetailsLocationCard(
                        location: state.location!,
                        onOpenMap: _handleOpenOnMap,
                        onRetryLocation: () =>
                            _viewModel.doIntent(const RetryDriverLocationEvent()),
                      ),
                    const SizedBox(height: Spacing.xs),
                    // Active Boxes Section
                    if (state.isBoxesLoading && state.activeBoxes == null)
                      const DriverDetailsBoxesShimmer()
                    else if (state.boxesFailure != null &&
                        state.activeBoxes == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.base,
                          vertical: Spacing.xs,
                        ),
                        child: InlineApiErrorWidget(
                          failure: state.boxesFailure!,
                          onRetry: () =>
                              _viewModel.doIntent(const RetryDriverBoxesEvent()),
                        ),
                      )
                    else
                      DriverDetailsBoxesCard(
                        boxes: state.activeBoxes ?? const [],
                        onSelectBox: _handleBoxTap,
                      ),
                    const SizedBox(height: Spacing.xs),
                    // Daily Performance Summary
                    DriverDetailsPerformanceCard(dailySummary: dailySummary),
                    const SizedBox(height: Spacing.xs),
                    // External Action Buttons
                    DriverDetailsActionButtons(
                      onCall: hasValidPhone
                          ? () => _handleCall(phoneNumber)
                          : null,
                      onSelectSms: hasValidPhone
                          ? () => _handleSms(phoneNumber)
                          : null,
                      onSelectWhatsApp: hasValidPhone
                          ? () => _handleWhatsApp(phoneNumber)
                          : null,
                    ),
                    const SizedBox(height: Spacing.base),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

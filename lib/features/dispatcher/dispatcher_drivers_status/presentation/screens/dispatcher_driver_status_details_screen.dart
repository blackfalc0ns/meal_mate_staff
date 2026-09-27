import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/dispatcher_map_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/dispatcher_driver_location_entity.dart';
import '../manager/dispatcher_driver_details_event.dart';
import '../manager/dispatcher_driver_details_state.dart';
import '../manager/dispatcher_driver_details_view_model.dart';
import '../services/driver_contact_launcher.dart';
import '../widgets/dispatcher_driver_details_app_bar.dart';
import '../widgets/dispatcher_driver_details_contact_card.dart';
import '../widgets/dispatcher_driver_details_documents_card.dart';
import '../widgets/dispatcher_driver_details_location_card.dart';
import '../widgets/dispatcher_driver_details_metrics_row.dart';
import '../widgets/dispatcher_driver_details_performance_card.dart';
import '../widgets/dispatcher_driver_details_profile_card.dart';
import '../widgets/dispatcher_driver_details_shimmer.dart';
import '../widgets/dispatcher_driver_details_vehicle_card.dart';

class DispatcherDriverStatusDetailsScreen extends StatefulWidget {
  const DispatcherDriverStatusDetailsScreen({
    super.key,
    required this.driverId,
    this.viewModel,
    this.contactLauncher,
    this.onBack,
    this.onOpenMap,
  });

  final String driverId;
  final DispatcherDriverDetailsViewModel? viewModel;
  final DriverContactLauncher? contactLauncher;
  final VoidCallback? onBack;
  final VoidCallback? onOpenMap;

  @override
  State<DispatcherDriverStatusDetailsScreen> createState() =>
      _DispatcherDriverStatusDetailsScreenState();
}

class _DispatcherDriverStatusDetailsScreenState
    extends State<DispatcherDriverStatusDetailsScreen> {
  late final DispatcherDriverDetailsViewModel _viewModel;
  late final bool _isLocalViewModel;
  late final DriverContactLauncher _contactLauncher;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isLocalViewModel = false;
    } else {
      _viewModel = getIt<DispatcherDriverDetailsViewModel>(
        param1: widget.driverId,
      );
      _isLocalViewModel = true;
    }

    _contactLauncher =
        widget.contactLauncher ??
        (getIt.isRegistered<DriverContactLauncher>()
            ? getIt<DriverContactLauncher>()
            : const DriverContactLauncherImpl());

    unawaited(_viewModel.doIntent(Started(widget.driverId)));
  }

  @override
  void dispose() {
    if (_isLocalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  Future<void> _handleCall(String? phoneNumber) async {
    final success = await _contactLauncher.launchPhone(phoneNumber);
    if (!success && mounted) {
      CustomSnackbar.showError(
        context: context,
        message: context.localization.driverDetailsUnableToCall,
      );
    }
  }

  Future<void> _handleChat(String? phoneNumber) async {
    final success = await _contactLauncher.launchWhatsApp(phoneNumber);
    if (!success && mounted) {
      CustomSnackbar.showError(
        context: context,
        message: context.localization.driverDetailsUnableToWhatsApp,
      );
    }
  }

  void _handleOpenMap() {
    if (widget.onOpenMap != null) {
      widget.onOpenMap!();
      return;
    }

    unawaited(
      Navigator.of(context).pushNamed(
        AppRoutes.dispatcherMap,
        arguments: DispatcherMapRouteArgs(focusDriverId: widget.driverId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DispatcherDriverDetailsAppBar(onBack: widget.onBack),
      body: SafeArea(
        bottom: false,
        child:
            BlocBuilder<
              DispatcherDriverDetailsViewModel,
              DispatcherDriverDetailsState
            >(
              bloc: _viewModel,
              builder: (context, state) {
                if (state.isInitialLoading && state.details == null) {
                  return const DispatcherDriverDetailsShimmer();
                }

                if (state.failure != null && state.details == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.screenH),
                      child: ApiErrorWidget.fromTypedFailure(
                        failure: state.failure!,
                        onRetry: () => unawaited(
                          _viewModel.doIntent(const RetryRequested()),
                        ),
                      ),
                    ),
                  );
                }

                final details = state.details;
                if (details == null) {
                  return const DispatcherDriverDetailsShimmer();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _viewModel.doIntent(const Refreshed());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.inlineFailure != null) ...[
                          const SizedBox(height: Spacing.xs),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.base,
                            ),
                            child: InlineApiErrorWidget(
                              failure: state.inlineFailure!,
                              onRetry: () => unawaited(
                                _viewModel.doIntent(const Refreshed()),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: Spacing.xs),
                        DispatcherDriverDetailsProfileCard(
                          details: details,
                          isUpdatingAvailability: state.isUpdatingAvailability,
                          onToggleAvailable: (val) {
                            unawaited(
                              _viewModel.doIntent(AvailabilityChanged(val)),
                            );
                          },
                        ),
                        const SizedBox(height: Spacing.sm),
                        DispatcherDriverDetailsMetricsRow(details: details),
                        const SizedBox(height: Spacing.sm),
                        DispatcherDriverDetailsContactCard(
                          phoneNumber: details.phoneNumber,
                          onCall: () => _handleCall(details.phoneNumber),
                          onChat: () => _handleChat(details.phoneNumber),
                        ),
                        if (details.vehicle != null) ...[
                          const SizedBox(height: Spacing.sm),
                          DispatcherDriverDetailsVehicleCard(
                            vehicle: details.vehicle!,
                          ),
                        ],
                        const SizedBox(height: Spacing.sm),
                        DispatcherDriverDetailsLocationCard(
                          location:
                              details.location ??
                              const DispatcherDriverLocationEntity(),
                          onShowOnMap: _handleOpenMap,
                        ),
                        if (details.performance != null) ...[
                          const SizedBox(height: Spacing.sm),
                          DispatcherDriverDetailsPerformanceCard(
                            performance: details.performance!,
                          ),
                        ],
                        if (details.documents.isNotEmpty) ...[
                          const SizedBox(height: Spacing.sm),
                          DispatcherDriverDetailsDocumentsCard(
                            documents: details.documents,
                          ),
                        ],
                        const SizedBox(
                          height: Spacing.bottomNavHeight + Spacing.lg,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

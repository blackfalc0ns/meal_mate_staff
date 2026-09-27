import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_received_box_item_entity.dart';
import '../../domain/fake_data/driver_boxes_received_fake_data.dart';
import '../manager/driver_pickup_summary_event.dart';
import '../manager/driver_pickup_summary_state.dart';
import '../manager/driver_pickup_summary_view_model.dart';
import '../widgets/driver_boxes_received_action_button.dart';
import '../widgets/driver_boxes_received_header.dart';
import '../widgets/driver_boxes_received_info_card.dart';
import '../widgets/driver_boxes_received_safety_banner.dart';
import '../widgets/driver_boxes_received_shimmer.dart';
import '../widgets/driver_boxes_received_success_banner.dart';
import '../widgets/driver_received_box_card.dart';
import '../widgets/driver_received_boxes_header_bar.dart';

class DriverBoxesReceivedScreen extends StatefulWidget {
  const DriverBoxesReceivedScreen({
    super.key,
    this.boxes,
    this.onStartDelivery,
    this.tripId,
    this.viewModel,
  });

  final List<DriverReceivedBoxItemEntity>? boxes;
  final VoidCallback? onStartDelivery;
  final String? tripId;
  final DriverPickupSummaryViewModel? viewModel;

  @override
  State<DriverBoxesReceivedScreen> createState() =>
      _DriverBoxesReceivedScreenState();
}

class _DriverBoxesReceivedScreenState extends State<DriverBoxesReceivedScreen> {
  late final DriverPickupSummaryViewModel _viewModel;
  late final bool _isInternalViewModel;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else {
      _viewModel = getIt<DriverPickupSummaryViewModel>();
      _isInternalViewModel = true;
    }

    if (widget.tripId != null && widget.tripId!.isNotEmpty) {
      _viewModel.doIntent(LoadDriverPickupSummaryEvent(widget.tripId!));
    }
  }

  @override
  void dispose() {
    if (_isInternalViewModel) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _handleStartDelivery() {
    if (widget.onStartDelivery != null && widget.boxes != null) {
      widget.onStartDelivery!();
      return;
    }
    _viewModel.doIntent(const StartDriverTripEvent());
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocConsumer<DriverPickupSummaryViewModel, DriverPickupSummaryState>(
      bloc: _viewModel,
      listenWhen: (prev, curr) =>
          prev.startTripResult != curr.startTripResult &&
          curr.startTripResult != null,
      listener: (context, state) {
        if (state.startTripResult != null) {
          if (widget.onStartDelivery != null) {
            widget.onStartDelivery!();
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.driverStartDeliveryRoute,
              (route) => false,
            );
          }
        }
      },
      builder: (context, state) {
        // Initial loading without content
        final isInitial =
            (state.isInitialLoading && state.summary == null) ||
            (!state.hasLoadedOnce && state.failure == null);
        if (isInitial && widget.boxes == null) {
          return Scaffold(
            backgroundColor: color.surface,
            appBar: const DriverBoxesReceivedHeader(),
            body: const SafeArea(child: DriverBoxesReceivedShimmer()),
          );
        }

        // Full-page error without content
        if (state.failure != null &&
            state.summary == null &&
            widget.boxes == null) {
          return Scaffold(
            backgroundColor: color.surface,
            appBar: const DriverBoxesReceivedHeader(),
            body: SafeArea(
              child: Center(
                child: ApiErrorWidget.fromTypedFailure(
                  failure: state.failure!,
                  onRetry: () => _viewModel.doIntent(
                    const RetryDriverPickupSummaryEvent(),
                  ),
                ),
              ),
            ),
          );
        }

        // Empty state when boxes list is empty
        if (state.summary != null &&
            state.summary!.boxes.isEmpty &&
            widget.boxes == null) {
          return Scaffold(
            backgroundColor: color.surface,
            appBar: const DriverBoxesReceivedHeader(),
            body: SafeArea(
              child: Center(
                child: EmptyStateWidget(
                  onAction: () => _viewModel.doIntent(
                    const RetryDriverPickupSummaryEvent(),
                  ),
                ),
              ),
            ),
          );
        }

        final List<DriverReceivedBoxItemEntity> displayBoxes =
            widget.boxes ??
            (state.summary != null
                ? state.summary!.boxes.asMap().entries.map((entry) {
                    final box = entry.value;
                    return DriverReceivedBoxItemEntity(
                      indexNumber: entry.key + 1,
                      boxCode: box.boxCode,
                      condition: box.statusText.isNotEmpty
                          ? box.statusText
                          : (box.isReceived ? 'سليم' : 'قيد الفحص'),
                      isReceived: box.isReceived,
                    );
                  }).toList()
                : DriverBoxesReceivedFakeData.defaultReceivedBoxes);

        final canStart = (state.canStartTrip) || (widget.boxes != null);

        return Scaffold(
          backgroundColor: color.surface,
          appBar: const DriverBoxesReceivedHeader(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Spacing.base),
                  const DriverBoxesReceivedSuccessBanner(),
                  const SizedBox(height: Spacing.sm),
                  const DriverBoxesReceivedInfoCard(),
                  if (state.failure != null && state.summary != null) ...[
                    const SizedBox(height: Spacing.md),
                    InlineApiErrorWidget(
                      failure: state.failure!,
                      onRetry: () => _viewModel.doIntent(
                        const RetryDriverPickupSummaryEvent(),
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.lg),
                  DriverReceivedBoxesHeaderBar(count: displayBoxes.length),
                  const SizedBox(height: Spacing.sm),
                  for (final item in displayBoxes) ...[
                    DriverReceivedBoxCard(item: item),
                    const SizedBox(height: Spacing.sm),
                  ],
                  const SizedBox(height: Spacing.xs),
                  const DriverBoxesReceivedSafetyBanner(),
                  const SizedBox(height: Spacing.lg),
                  DriverBoxesReceivedActionButton(
                    onPressed: _handleStartDelivery,
                    isLoading: state.isActionLoading,
                    isEnabled: canStart,
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

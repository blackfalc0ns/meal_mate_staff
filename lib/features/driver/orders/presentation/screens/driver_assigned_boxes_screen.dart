import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_assigned_box_entity.dart';
import '../../domain/entities/driver_boxes_filter_type.dart';
import '../../domain/entities/driver_pickup_manifest_entity.dart';
import '../manager/driver_pickup_manifest_event.dart';
import '../manager/driver_pickup_manifest_state.dart';
import '../manager/driver_pickup_manifest_view_model.dart';
import '../widgets/driver_assigned_box_card.dart';
import '../widgets/driver_assigned_boxes_shimmer.dart';
import '../widgets/driver_boxes_filter_bar.dart';
import '../widgets/driver_boxes_header_logo.dart';
import '../widgets/driver_boxes_stats_banner.dart';
import '../widgets/driver_boxes_title_bar.dart';

class DriverAssignedBoxesScreen extends StatefulWidget {
  const DriverAssignedBoxesScreen({
    super.key,
    this.viewModel,
    this.initialBoxes,
    this.onCompleteAction,
  });

  final DriverPickupManifestViewModel? viewModel;
  final List<DriverAssignedBoxEntity>? initialBoxes;
  final ValueChanged<DriverAssignedBoxEntity>? onCompleteAction;

  @override
  State<DriverAssignedBoxesScreen> createState() =>
      _DriverAssignedBoxesScreenState();
}

class _DriverAssignedBoxesScreenState extends State<DriverAssignedBoxesScreen> {
  late final DriverPickupManifestViewModel _viewModel;
  bool _isLocalViewModel = false;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
    } else {
      _viewModel = getIt<DriverPickupManifestViewModel>();
      _isLocalViewModel = true;
    }

    if (widget.initialBoxes != null) {
      // Legacy test compatibility: seed ViewModel with initial boxes
      final seededManifest = DriverPickupManifestEntity(
        tripId: 'test-trip',
        tripCode: 'TRIP-TEST',
        driverId: 'test-driver',
        driverName: 'Driver',
        totalBoxesCount: widget.initialBoxes!.length,
        totalMealsCount: widget.initialBoxes!.fold(
          0,
          (sum, b) => sum + b.mealsCount,
        ),
        pendingScanBoxesCount:
            widget.initialBoxes!.where((b) => !b.isPickedUp).length,
        pickedUpBoxesCount:
            widget.initialBoxes!.where((b) => b.isPickedUp).length,
        allBoxesPickedUp: widget.initialBoxes!.every((b) => b.isPickedUp),
        canStartTrip: false,
        boxes: widget.initialBoxes!,
      );
      _viewModel.emit(
        DriverPickupManifestState(
          manifest: seededManifest,
          isInitialLoading: false,
          hasLoadedOnce: true,
        ),
      );
    } else if (!_viewModel.state.hasLoadedOnce && _viewModel.state.failure == null) {
      _viewModel.doIntent(const LoadDriverPickupManifestEvent());
    }
  }

  @override
  void dispose() {
    if (_isLocalViewModel) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _handleFilterChanged(DriverBoxesFilterType filter) {
    _viewModel.doIntent(SelectDriverBoxesFilterEvent(filter));
  }

  Future<void> _handleBoxAction(DriverAssignedBoxEntity box) async {
    if (widget.onCompleteAction != null) {
      widget.onCompleteAction!(box);
      return;
    }

    if (!box.isPickedUp) {
      final result = await context.pushNamed(
        AppRoutes.driverConfirmReceipt,
        arguments: box,
      );
      if (result == true && mounted) {
        _viewModel.doIntent(const RefreshDriverPickupManifestEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: color.surface,
        body: SafeArea(
          child: BlocBuilder<DriverPickupManifestViewModel, DriverPickupManifestState>(
            builder: (context, state) {
              if (state.isInitialLoading && state.manifest == null) {
                return const DriverAssignedBoxesShimmer();
              }

              if (state.failure != null && state.manifest == null) {
                return ApiErrorWidget.fromTypedFailure(
                  failure: state.failure!,
                  onRetry: () => _viewModel.doIntent(
                    const RetryDriverPickupManifestEvent(),
                  ),
                );
              }

              final manifest = state.manifest;
              final boxes = manifest?.boxes ?? const [];

              return RefreshIndicator(
                onRefresh: () async {
                  await _viewModel.doIntent(
                    const RefreshDriverPickupManifestEvent(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: Spacing.sm),
                      const DriverBoxesHeaderLogo(),
                      const SizedBox(height: Spacing.md),
                      const DriverBoxesTitleBar(),
                      const SizedBox(height: Spacing.sm),
                      DriverBoxesStatsBanner(
                        totalMeals: manifest?.totalMealsCount ?? 0,
                        totalBoxes: manifest?.totalBoxesCount ?? 0,
                      ),
                      const SizedBox(height: Spacing.md),
                      DriverBoxesFilterBar(
                        selectedFilter: state.selectedFilter,
                        onFilterChanged: _handleFilterChanged,
                      ),
                      if (state.failure != null) ...[
                        const SizedBox(height: Spacing.sm),
                        InlineApiErrorWidget(
                          failure: state.failure!,
                          onRetry: () => _viewModel.doIntent(
                            const RefreshDriverPickupManifestEvent(),
                          ),
                        ),
                      ],
                      const SizedBox(height: Spacing.sm),
                      Expanded(
                        child: state.isFilterLoading
                            ? const SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: DriverAssignedBoxesCardsShimmer(),
                              )
                            : boxes.isEmpty
                                ? LayoutBuilder(
                                    builder: (context, constraints) =>
                                        SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
                                        child: EmptyStateWidget(
                                          onAction: () => _viewModel.doIntent(
                                            const RefreshDriverPickupManifestEvent(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    key: ValueKey(state.selectedFilter),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(
                                      bottom:
                                          Spacing.bottomNavHeight + Spacing.md,
                                    ),
                                    itemCount: boxes.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: Spacing.sm),
                                    itemBuilder: (context, index) {
                                      final box = boxes[index];
                                      return DriverAssignedBoxCard(
                                        box: box,
                                        onCompleteAction: () =>
                                            _handleBoxAction(box),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

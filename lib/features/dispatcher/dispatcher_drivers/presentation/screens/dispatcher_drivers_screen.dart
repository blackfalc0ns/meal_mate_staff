import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import '../../../../../config/routing/arguments/dispatcher_map_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import '../../domain/entities/dispatcher_driver_view_mode.dart';
import '../../domain/entities/dispatcher_drivers_mode.dart';
import '../../domain/entities/driver_assignment_result_entity.dart';
import '../manager/dispatcher_drivers_event.dart';
import '../manager/dispatcher_drivers_state.dart';
import '../manager/dispatcher_drivers_view_model.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../widgets/dispatcher_drivers_area_chips.dart';
import '../widgets/dispatcher_drivers_content_list.dart';
import '../widgets/dispatcher_drivers_content_shimmer.dart';
import '../widgets/dispatcher_drivers_empty_state.dart';
import '../widgets/dispatcher_drivers_header.dart';
import '../widgets/dispatcher_drivers_kpi_card.dart';
import '../widgets/dispatcher_drivers_map_button.dart';
import '../widgets/dispatcher_drivers_shimmer.dart';
import '../widgets/dispatcher_drivers_sort_sheet.dart';
import '../widgets/dispatcher_drivers_view_switcher.dart';

class DispatcherDriversScreen extends StatefulWidget {
  const DispatcherDriversScreen({
    super.key,
    this.args = const DispatcherDriversRouteArgs.browse(),
    this.viewModel,
    this.onSelectDriver,
    this.onBrowseDriver,
    this.onAssignmentCompleted,
    this.onBack,
    this.onViewOnMap,
  });

  final DispatcherDriversRouteArgs args;
  final DispatcherDriversViewModel? viewModel;
  final ValueChanged<DispatcherDriverEntity>? onSelectDriver;
  final ValueChanged<DispatcherDriverEntity>? onBrowseDriver;
  final ValueChanged<DriverAssignmentResultEntity>? onAssignmentCompleted;
  final VoidCallback? onBack;
  final dynamic onViewOnMap;

  @override
  State<DispatcherDriversScreen> createState() =>
      _DispatcherDriversScreenState();
}

class _DispatcherDriversScreenState extends State<DispatcherDriversScreen> {
  late final DispatcherDriversViewModel _viewModel;
  late final bool _isLocalViewModel;
  int _lastHandledNoticeId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isLocalViewModel = false;
    } else {
      _viewModel = getIt<DispatcherDriversViewModel>(param1: widget.args);
      _isLocalViewModel = true;
    }
    unawaited(_viewModel.doIntent(const LoadDispatcherDriversEvent()));
  }

  @override
  void dispose() {
    if (_isLocalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _handleDriverSelected(DispatcherDriverEntity driver) {
    if (widget.args.mode == DispatcherDriversMode.browse) {
      if (widget.onBrowseDriver != null) {
        widget.onBrowseDriver!(driver);
        return;
      }
      if (widget.onSelectDriver != null) {
        widget.onSelectDriver!(driver);
        return;
      }
      unawaited(
        Navigator.of(context).pushNamed(AppRoutes.dispatcherDriverDetails),
      );
    } else {
      if (!driver.isAvailableForSelection || _viewModel.state.isAssigning) {
        return;
      }
      unawaited(_viewModel.doIntent(AssignRosterDriverEvent(driver)));
    }
  }

  Future<void> _showSortSheet(
    BuildContext context,
    DispatcherDriversState state,
  ) async {
    final sort = await DispatcherDriversSortSheet.show(
      context,
      currentSort: state.sort,
    );
    if (sort != null && mounted) {
      unawaited(_viewModel.doIntent(ChangeDispatcherDriversSortEvent(sort)));
    }
  }

  void _handleViewOnMap(DispatcherDriversState state) {
    final mapArgs = state.query.view == DispatcherDriverViewMode.byArea
        ? DispatcherMapRouteArgs(
            areaKey: state.query.areaKey ?? state.roster?.selectedAreaKey,
            areaName: state.query.areaName ?? state.roster?.selectedAreaName,
          )
        : null;

    if (widget.onViewOnMap != null) {
      final cb = widget.onViewOnMap;
      if (cb is void Function(DispatcherMapRouteArgs?)) {
        cb(mapArgs);
      } else if (cb is void Function()) {
        cb();
      } else if (cb is Function) {
        try {
          (cb as dynamic)(mapArgs);
        } catch (_) {
          (cb as dynamic)();
        }
      }
      return;
    }
    unawaited(
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.dispatcherMap, arguments: mapArgs),
    );
  }

  void _handleStateListener(
    BuildContext context,
    DispatcherDriversState state,
  ) {
    if (state.noticeId > _lastHandledNoticeId) {
      _lastHandledNoticeId = state.noticeId;

      if (state.assignmentResult != null) {
        final message = state.assignmentResult!.message.isNotEmpty
            ? state.assignmentResult!.message
            : 'تم إسناد الطلب بنجاح';
        CustomSnackbar.showSuccess(context: context, message: message);
        if (widget.onAssignmentCompleted != null) {
          widget.onAssignmentCompleted!(state.assignmentResult!);
        } else {
          Navigator.of(context).pop(state.assignmentResult);
        }
        return;
      }

      if (state.assignmentFailure != null) {
        CustomSnackbar.showError(
          context: context,
          message: state.assignmentFailure!.errorMessage,
        );
        return;
      }

      if (state.nonFatalFailure != null) {
        CustomSnackbar.showError(
          context: context,
          message: state.nonFatalFailure!.errorMessage,
        );
        return;
      }
    }
  }

  String _resolveSectionTitle(
    BuildContext context,
    DispatcherDriversState state,
  ) {
    final roster = state.roster;
    if (roster != null && roster.sectionTitle.isNotEmpty) {
      return roster.sectionTitle;
    }
    final locale = context.localization;
    final count = state.sortedDrivers.length;
    if (state.query.view == DispatcherDriverViewMode.byArea) {
      final areaName = state.query.areaName ?? roster?.selectedAreaName ?? '';
      return locale.driversSectionTitle(areaName, count);
    }
    return locale.driversAllSectionTitle(count);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DispatcherDriversViewModel, DispatcherDriversState>(
      bloc: _viewModel,
      listenWhen: (prev, curr) => curr.noticeId > _lastHandledNoticeId,
      listener: _handleStateListener,
      builder: (context, state) {
        if (!state.hasLoadedOnce && state.isInitialLoading) {
          return Scaffold(
            appBar: DispatcherDriversHeader(
              onBack: widget.onBack,
              onFilter: null,
            ),
            body: const SafeArea(child: DispatcherDriversShimmer()),
          );
        }

        if (!state.hasLoadedOnce && state.initialFailure != null) {
          return Scaffold(
            appBar: DispatcherDriversHeader(
              onBack: widget.onBack,
              onFilter: null,
            ),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.screenH),
                  child: ApiErrorWidget.fromTypedFailure(
                    failure: state.initialFailure!,
                    onRetry: () => unawaited(
                      _viewModel.doIntent(const RetryDispatcherDriversEvent()),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final selectedAreaKey =
            state.query.areaKey ?? state.roster?.selectedAreaKey;

        return Scaffold(
          appBar: DispatcherDriversHeader(
            onBack: widget.onBack,
            onFilter: () => _showSortSheet(context, state),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () =>
                  _viewModel.doIntent(const RefreshDispatcherDriversEvent()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DispatcherDriversViewSwitcher(
                      selectedViewMode: state.query.view,
                      onViewModeChanged: (mode) => unawaited(
                        _viewModel.doIntent(
                          ChangeDispatcherDriversViewEvent(mode),
                        ),
                      ),
                    ),
                    if (state.query.view == DispatcherDriverViewMode.byArea &&
                        (state.roster?.areas.isNotEmpty ?? false)) ...[
                      const SizedBox(height: Spacing.xs),
                      DispatcherDriversAreaChips(
                        areas: state.roster!.areas,
                        selectedAreaKey: selectedAreaKey,
                        onAreaSelected: (area) => unawaited(
                          _viewModel.doIntent(
                            ChangeDispatcherDriversAreaEvent(
                              area.areaKey,
                              area.name,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.xs),
                    if (state.isReplacementLoading) ...[
                      const DispatcherDriversContentShimmer(),
                    ] else if (state.isEmpty) ...[
                      DispatcherDriversEmptyState(
                        onRefresh: () => unawaited(
                          _viewModel.doIntent(
                            const RefreshDispatcherDriversEvent(),
                          ),
                        ),
                      ),
                    ] else ...[
                      if (state.roster != null)
                        DispatcherDriversKpiCard(kpi: state.roster!.counts),
                      const SizedBox(height: Spacing.sm),
                      DispatcherDriversContentList(
                        transitionKey: '${state.query.view}-$selectedAreaKey',
                        isTransitionReversed: false,
                        sectionTitle: _resolveSectionTitle(context, state),
                        drivers: state.sortedDrivers,
                        assigningDriverId: state.assigningDriverId,
                        onSort: () => _showSortSheet(context, state),
                        onSelectDriver: _handleDriverSelected,
                      ),
                    ],
                    const SizedBox(height: Spacing.xs),
                    DispatcherDriversMapButton(
                      onTap: () => _handleViewOnMap(state),
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

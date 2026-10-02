import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/dispatcher_driver_details_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../manager/dispatcher_drivers_status_event.dart';
import '../manager/dispatcher_drivers_status_state.dart';
import '../manager/dispatcher_drivers_status_view_model.dart';
import '../widgets/dispatcher_drivers_status_card.dart';
import '../widgets/dispatcher_drivers_status_count_header.dart';
import '../widgets/dispatcher_drivers_status_filter_button.dart';
import '../widgets/dispatcher_drivers_status_filter_sheet.dart';
import '../widgets/dispatcher_drivers_status_header.dart';
import '../widgets/dispatcher_drivers_status_kpi_section.dart';
import '../widgets/dispatcher_drivers_status_pagination.dart';
import '../widgets/dispatcher_drivers_status_search_bar.dart';
import '../widgets/dispatcher_drivers_status_shimmer.dart';
import '../widgets/dispatcher_drivers_status_sort_button.dart';

class DispatcherDriversStatusScreen extends StatefulWidget {
  const DispatcherDriversStatusScreen({super.key, this.viewModel});

  final DispatcherDriversStatusViewModel? viewModel;

  @override
  State<DispatcherDriversStatusScreen> createState() =>
      _DispatcherDriversStatusScreenState();
}

class _DispatcherDriversStatusScreenState
    extends State<DispatcherDriversStatusScreen> {
  late final DispatcherDriversStatusViewModel _viewModel;
  late final bool _isLocalViewModel;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isLocalViewModel = false;
    } else {
      _viewModel = getIt<DispatcherDriversStatusViewModel>();
      _isLocalViewModel = true;
    }
    unawaited(_viewModel.doIntent(const LoadDispatcherDriversStatusEvent()));
  }

  @override
  void dispose() {
    if (_isLocalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  Future<void> _handleFilterTap() async {
    final filter = await DispatcherDriversStatusFilterSheet.show(
      context: context,
      currentFilter: _viewModel.state.selectedFilter,
    );
    if (!mounted) return;
    unawaited(_viewModel.doIntent(FilterDriversStatusEvent(filter)));
  }

  void _handleKpiFilter(DispatcherDriverStatusType? status) {
    if (_viewModel.state.selectedFilter == status) {
      unawaited(_viewModel.doIntent(const FilterDriversStatusEvent(null)));
    } else {
      unawaited(_viewModel.doIntent(FilterDriversStatusEvent(status)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        bottom: false,
        child:
            BlocBuilder<
              DispatcherDriversStatusViewModel,
              DispatcherDriversStatusState
            >(
              bloc: _viewModel,
              builder: (context, state) {
                if (state.isInitialLoading && state.summary == null) {
                  return const DispatcherDriversStatusShimmer();
                }

                if (state.initialFailure != null && state.summary == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.screenH),
                      child: ApiErrorWidget.fromTypedFailure(
                        failure: state.initialFailure!,
                        onRetry: () => unawaited(
                          _viewModel.doIntent(
                            const LoadDispatcherDriversStatusEvent(),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final summary = state.summary;
                if (summary == null) {
                  return const DispatcherDriversStatusShimmer();
                }

                final drivers = summary.items;

                return RefreshIndicator(
                  onRefresh: () async {
                    await _viewModel.doIntent(
                      const RefreshDispatcherDriversStatusEvent(),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DispatcherDriversStatusHeader(
                          restaurantName: summary.restaurantName,
                          role: summary.role,
                        ),
                        const SizedBox(height: Spacing.md),
                        DispatcherDriversStatusKpiSection(
                          kpis: summary.counts,
                          onSelectFilter: _handleKpiFilter,
                        ),
                        const SizedBox(height: Spacing.md),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.base,
                          ),
                          child: Row(
                            children: [
                              DispatcherDriversStatusFilterButton(
                                isActive: state.selectedFilter != null,
                                onTap: _handleFilterTap,
                              ),
                              const SizedBox(width: Spacing.xs),
                              DispatcherDriversStatusSortButton(
                                currentSort: state.query.sortBy,
                                onSortSelected: (sort) {
                                  unawaited(
                                    _viewModel.doIntent(
                                      SortDriversStatusEvent(sort),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: Spacing.xs),
                              Expanded(
                                child: DispatcherDriversStatusSearchBar(
                                  onChanged: (q) => unawaited(
                                    _viewModel.doIntent(
                                      SearchDriversStatusEvent(q),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.actionFailure != null) ...[
                          const SizedBox(height: Spacing.sm),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.base,
                            ),
                            child: InlineApiErrorWidget(
                              failure: state.actionFailure!,
                              onRetry: () => unawaited(
                                _viewModel.doIntent(
                                  const RefreshDispatcherDriversStatusEvent(),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: Spacing.sm),
                        DispatcherDriversStatusCountHeader(
                          count: summary.pagination.totalItems,
                        ),
                        const SizedBox(height: Spacing.xs),
                        if (drivers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.base,
                              vertical: Spacing.xl,
                            ),
                            child: EmptyStateWidget(
                              title: context.localization.driversStatusEmpty,
                              description: '',
                            ),
                          )
                        else ...[
                          ...drivers.map(
                            (driver) => DispatcherDriversStatusCard(
                              key: ValueKey(driver.id),
                              driver: driver,
                              isToggling: state.togglingDriverIds.contains(
                                driver.id,
                              ),
                              onToggle: (val) => unawaited(
                                _viewModel.doIntent(
                                  ToggleDriverStatusEvent(driver.id, val),
                                ),
                              ),
                              onTap: () {
                                unawaited(
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.dispatcherDriverStatusDetails,
                                    arguments: DispatcherDriverDetailsRouteArgs(
                                      driverId: driver.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          DispatcherDriversStatusPagination(
                            pagination: summary.pagination,
                            onPageChanged: (page) => unawaited(
                              _viewModel.doIntent(
                                ChangeDriversStatusPageEvent(page),
                              ),
                            ),
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

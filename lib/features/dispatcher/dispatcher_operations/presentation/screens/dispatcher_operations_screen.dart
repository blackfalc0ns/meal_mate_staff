import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/operation_item_entity.dart';
import '../../domain/entities/operations_date_preset.dart';
import '../../domain/entities/operations_query_entity.dart';
import '../manager/operations_event.dart';
import '../manager/operations_state.dart';
import '../manager/operations_view_model.dart';
import '../widgets/dispatcher_operations_shimmer.dart';
import '../widgets/operations_app_bar.dart';
import '../widgets/operations_card.dart';
import '../widgets/operations_cards_shimmer.dart';
import '../widgets/operations_date_filter_sheet.dart';
import '../widgets/operations_empty_state.dart';
import '../widgets/operations_pagination_bar.dart';
import '../widgets/operations_search_filter_bar.dart';
import '../widgets/operations_status_tabs.dart';

class DispatcherOperationsScreen extends StatefulWidget {
  const DispatcherOperationsScreen({
    super.key,
    this.viewModel,
    this.onOpenBoxTracking,
  });

  final OperationsViewModel? viewModel;
  final ValueChanged<String>? onOpenBoxTracking;

  @override
  State<DispatcherOperationsScreen> createState() =>
      _DispatcherOperationsScreenState();
}

class _DispatcherOperationsScreenState
    extends State<DispatcherOperationsScreen> {
  late final OperationsViewModel _viewModel;
  late final bool _isExternalViewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _isExternalViewModel = widget.viewModel != null;
    _viewModel = widget.viewModel ?? getIt<OperationsViewModel>();
    _searchController = TextEditingController(
      text: _viewModel.state.query.search,
    );

    if (!_viewModel.state.hasLoadedOnce && !_viewModel.state.isInitialLoading) {
      unawaited(_viewModel.doIntent(const LoadOperationsEvent()));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (!_isExternalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _openDateFilterSheet(BuildContext context, OperationsState state) {
    unawaited(
      OperationsDateFilterSheet.show(
        context,
        selectedPreset: state.query.datePreset,
        initialCustomFrom: state.query.fromDateUtc,
        initialCustomTo: state.query.toDateUtc,
        onPresetSelected: (preset) {
          unawaited(
            _viewModel.doIntent(ChangeOperationsDatePresetEvent(preset)),
          );
        },
        onCustomRangeSelected: (fromUtc, toUtc) {
          unawaited(
            _viewModel.doIntent(
              ChangeOperationsCustomDateRangeEvent(
                fromDateUtc: fromUtc,
                toDateUtc: toUtc,
              ),
            ),
          );
        },
      ),
    );
  }

  String _resolveDatePresetLabel(
    BuildContext context,
    OperationsQueryEntity query,
  ) {
    final locale = context.localization;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    switch (query.datePreset) {
      case OperationsDatePreset.today:
        return locale.supportDatePresetToday;
      case OperationsDatePreset.last7Days:
        return locale.operationsLast7Days;
      case OperationsDatePreset.last30Days:
        return isArabic ? 'آخر 30 يوماً' : locale.supportDatePresetLast30Days;
      case OperationsDatePreset.all:
        return locale.operationsTabAll;
      case OperationsDatePreset.custom:
        if (query.fromDateUtc != null && query.toDateUtc != null) {
          final fromLocal = query.fromDateUtc!.toLocal();
          final toLocal = query.toDateUtc!.toLocal();
          return '${fromLocal.day}/${fromLocal.month} - ${toLocal.day}/${toLocal.month}';
        }
        return locale.supportDatePresetCustom;
    }
  }

  void _openBoxTracking(OperationItemEntity item) {
    final callback = widget.onOpenBoxTracking;
    if (callback != null) {
      callback(item.boxId);
      return;
    }
    // Route integration: when confirmed, navigate with raw boxId.
    // If route is not yet handling string boxId, callback seam provides isolation.
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocProvider.value(
      value: _viewModel,
      child: BlocListener<OperationsViewModel, OperationsState>(
        listenWhen: (previous, current) =>
            current.nonFatalFailure != null &&
            current.noticeId != previous.noticeId,
        listener: (context, state) {
          if (state.nonFatalFailure != null) {
            CustomSnackbar.showError(
              context: context,
              message: state.nonFatalFailure!.errorMessage,
            );
          }
        },
        child: BlocBuilder<OperationsViewModel, OperationsState>(
          builder: (context, state) {
            // 1. Initial Failure View
            if (state.response == null && state.initialFailure != null) {
              return Scaffold(
                backgroundColor: color.surfaceContainerLowest,
                appBar: OperationsAppBar(
                  onBackPressed: () => Navigator.of(context).pop(),
                  onFilterTap: () => _openDateFilterSheet(context, state),
                ),
                body: SafeArea(
                  child: Center(
                    child: ApiErrorWidget.fromTypedFailure(
                      failure: state.initialFailure!,
                      onRetry: () =>
                          _viewModel.doIntent(const RetryOperationsEvent()),
                    ),
                  ),
                ),
              );
            }

            // 2. Initial Shimmer Loading View
            if (state.response == null) {
              return Scaffold(
                backgroundColor: color.surfaceContainerLowest,
                appBar: OperationsAppBar(
                  onBackPressed: () => Navigator.of(context).pop(),
                  onFilterTap: () => _openDateFilterSheet(context, state),
                ),
                body: const SafeArea(child: DispatcherOperationsShimmer()),
              );
            }

            // 3. Loaded / Replacement Content View
            final operations = state.operations;

            return Scaffold(
              backgroundColor: color.surfaceContainerLowest,
              appBar: OperationsAppBar(
                onBackPressed: () => Navigator.of(context).pop(),
                onFilterTap: () => _openDateFilterSheet(context, state),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Search & Date Filter Bar
                    OperationsSearchFilterBar(
                      searchController: _searchController,
                      isEnabled: !state.isReplacementLoading,
                      onChanged: (text) => _viewModel.doIntent(
                        ChangeOperationsSearchEvent(text),
                      ),
                      onClearSearch: () => _viewModel.doIntent(
                        const ClearOperationsSearchEvent(),
                      ),
                      onDateFilterTap: () =>
                          _openDateFilterSheet(context, state),
                      dateLabel: _resolveDatePresetLabel(context, state.query),
                    ),
                    const SizedBox(height: 8),

                    // Status Tabs
                    OperationsStatusTabs(
                      counters: state.counters,
                      selectedStatus: state.query.status,
                      onStatusSelected: (status) => _viewModel.doIntent(
                        ChangeOperationsStatusEvent(status),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Cards Area
                    Expanded(
                      child: state.isReplacementLoading
                          ? const SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: OperationsCardsShimmer(),
                            )
                          : operations.isEmpty
                          ? RefreshIndicator(
                              onRefresh: () async {
                                await _viewModel.doIntent(
                                  const RefreshOperationsEvent(),
                                );
                              },
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: OperationsEmptyState(
                                  onRetry: () => _viewModel.doIntent(
                                    const RefreshOperationsEvent(),
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                await _viewModel.doIntent(
                                  const RefreshOperationsEvent(),
                                );
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: operations.length,
                                itemBuilder: (context, index) {
                                  final item = operations[index];
                                  return OperationsCard(
                                    item: item,
                                    onTap: (_) => _openBoxTracking(item),
                                  );
                                },
                              ),
                            ),
                    ),

                    // Pagination Bar
                    OperationsPaginationBar(
                      pagination: state.pagination,
                      isLoading: state.isReplacementLoading,
                      onPreviousTap: () => _viewModel.doIntent(
                        const GoToPreviousOperationsPageEvent(),
                      ),
                      onNextTap: () => _viewModel.doIntent(
                        const GoToNextOperationsPageEvent(),
                      ),
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

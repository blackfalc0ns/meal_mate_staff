import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/dispatcher_support_issue_entity.dart';
import '../manager/dispatcher_support_event.dart';
import '../manager/dispatcher_support_state.dart';
import '../manager/dispatcher_support_view_model.dart';
import '../widgets/support/dispatcher_support_date_filter_sheet.dart';
import '../widgets/support/dispatcher_support_filters_section.dart';
import '../widgets/support/dispatcher_support_footer_section.dart';
import '../widgets/support/dispatcher_support_header.dart';
import '../widgets/support/dispatcher_support_issues_section.dart';
import '../widgets/support/dispatcher_support_shimmer.dart';

class DispatcherSupportScreen extends StatefulWidget {
  const DispatcherSupportScreen({
    super.key,
    this.viewModel,
    this.onBack,
    this.onViewDetails,
    this.onAssignAlternativeDriver,
  });

  final DispatcherSupportViewModel? viewModel;
  final VoidCallback? onBack;
  final ValueChanged<DispatcherSupportIssueEntity>? onViewDetails;
  final ValueChanged<DispatcherSupportIssueEntity>? onAssignAlternativeDriver;

  @override
  State<DispatcherSupportScreen> createState() =>
      _DispatcherSupportScreenState();
}

class _DispatcherSupportScreenState extends State<DispatcherSupportScreen> {
  late final DispatcherSupportViewModel _viewModel;
  late final bool _isExternalViewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _isExternalViewModel = widget.viewModel != null;
    _viewModel = widget.viewModel ?? getIt<DispatcherSupportViewModel>();
    _searchController = TextEditingController(
      text: _viewModel.state.query.search,
    );

    if (!_viewModel.state.hasLoadedOnce && !_viewModel.state.isLoading) {
      _viewModel.doIntent(const LoadDispatcherSupportEvent());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (!_isExternalViewModel) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _openDateFilterSheet(
    BuildContext context,
    DispatcherSupportState state,
  ) {
    DispatcherSupportDateFilterSheet.show(
      context,
      selectedPreset: state.query.datePreset,
      initialCustomFrom: state.query.fromDateUtc,
      initialCustomTo: state.query.toDateUtc,
      onPresetSelected: (preset) {
        _viewModel.doIntent(ChangeDispatcherSupportDatePresetEvent(preset));
      },
      onCustomRangeSelected: (fromUtc, toUtc) {
        _viewModel.doIntent(
          ChangeDispatcherSupportCustomDateRangeEvent(
            fromDateUtc: fromUtc,
            toDateUtc: toUtc,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocProvider.value(
      value: _viewModel,
      child: BlocListener<DispatcherSupportViewModel, DispatcherSupportState>(
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
        child: BlocBuilder<DispatcherSupportViewModel, DispatcherSupportState>(
          builder: (context, state) {
            // 1. Initial Failure View
            if (state.response == null && state.initialFailure != null) {
              return Scaffold(
                backgroundColor: color.surface,
                appBar: DispatcherSupportHeader(
                  onFilterTap: () => _openDateFilterSheet(context, state),
                ),
                body: SafeArea(
                  child: ApiErrorWidget(
                    exception: state.initialFailure!.exception,
                    onRetry: () => _viewModel.doIntent(
                      const RetryDispatcherSupportEvent(),
                    ),
                  ),
                ),
              );
            }

            // 2. Initial Shimmer Loading View
            if (state.response == null) {
              return Scaffold(
                backgroundColor: color.surface,
                appBar: DispatcherSupportHeader(
                  onFilterTap: () => _openDateFilterSheet(context, state),
                ),
                body: const SafeArea(child: DispatcherSupportShimmer()),
              );
            }

            // 3. Loaded Content View
            final issues = state.response!.issues;

            return Scaffold(
              backgroundColor: color.surface,
              extendBody: true,
              appBar: DispatcherSupportHeader(
                onFilterTap: () => _openDateFilterSheet(context, state),
              ),
              body: SafeArea(
                top: false,
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _viewModel.doIntent(
                      const RetryDispatcherSupportEvent(),
                    );
                  },
                  child: CustomScrollView(
                    controller: _viewModel.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Section 1: Filters & KPIs
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: DispatcherSupportFiltersSection(
                            state: state,
                            searchController: _searchController,
                            viewModel: _viewModel,
                            onDateFilterTap: () =>
                                _openDateFilterSheet(context, state),
                          ),
                        ),
                      ),

                      // Section 2: Issues List / Empty State
                      DispatcherSupportIssuesSection(
                        issues: issues,
                        onRetry: () => _viewModel.doIntent(
                          const RetryDispatcherSupportEvent(),
                        ),
                        onViewDetails: widget.onViewDetails,
                        onAssignAlternativeDriver:
                            widget.onAssignAlternativeDriver,
                      ),

                      // Section 3: Footer (Pagination, Info Banner, Spacing)
                      if (issues.isNotEmpty)
                        DispatcherSupportFooterSection(
                          isNextPageLoading: state.isNextPageLoading,
                          hasPageFailure: state.pageFailure != null,
                          onRetry: () => _viewModel.doIntent(
                            const LoadNextDispatcherSupportPageEvent(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

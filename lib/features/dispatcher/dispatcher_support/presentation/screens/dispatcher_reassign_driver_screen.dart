import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../config/routing/arguments/dispatcher_support_route_arguments.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/di/di.dart';
import '../../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';
import '../../domain/entities/reassign_driver_candidate_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../../domain/usecase/get_replacement_driver_candidates_usecase.dart';
import '../../domain/usecase/reassign_dispatcher_issue_usecase.dart';
import '../../../dispatcher_driver_filter/presentation/widgets/dispatcher_driver_filter_bottom_sheet.dart';
import '../manager/reassignment/dispatcher_reassignment_state.dart';
import '../manager/reassignment/dispatcher_reassignment_view_model.dart';
import '../widgets/reassign_driver/dispatcher_reassign_empty_state_card.dart';
import '../widgets/reassign_driver/dispatcher_reassign_pagination_footer.dart';
import '../widgets/reassign_driver/dispatcher_reassign_shimmer.dart';
import '../widgets/reassign_driver/reassign_driver_app_bar.dart';
import '../widgets/reassign_driver/reassign_driver_bottom_button.dart';
import '../widgets/reassign_driver/reassign_driver_card.dart';
import '../widgets/reassign_driver/reassign_driver_issue_summary_card.dart';
import '../widgets/reassign_driver/reassign_driver_list_header.dart';

class DispatcherReassignDriverScreen extends StatefulWidget {
  const DispatcherReassignDriverScreen({
    super.key,
    this.issueId,
    this.issue,
    this.candidates,
    this.viewModel,
    this.onBack,
    this.onConfirm,
  });

  final String? issueId;
  final DispatcherIssueDetailEntity? issue;
  final List<ReassignDriverCandidateEntity>? candidates;
  final DispatcherReassignmentViewModel? viewModel;
  final VoidCallback? onBack;
  final ValueChanged<ReassignmentResultEntity>? onConfirm;

  @override
  State<DispatcherReassignDriverScreen> createState() =>
      _DispatcherReassignDriverScreenState();
}

class _DispatcherReassignDriverScreenState
    extends State<DispatcherReassignDriverScreen> {
  late final DispatcherReassignmentViewModel _viewModel;
  late final bool _isLocalViewModel;
  late final ScrollController _scrollController;
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isLocalViewModel = false;
      _initialized = true;
      unawaited(_viewModel.load());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      final resolvedIssueId = widget.issueId ??
          (routeArgs is DispatcherReassignDriverRouteArgs
              ? routeArgs.issueId
              : widget.issue?.issueId ?? '');

      _viewModel = DispatcherReassignmentViewModel(
        issueId: resolvedIssueId,
        getCandidatesUseCase: getIt<GetReplacementDriverCandidatesUseCase>(),
        reassignUseCase: getIt<ReassignDispatcherIssueUseCase>(),
      );
      _isLocalViewModel = true;
      unawaited(_viewModel.load());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    if (_isLocalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      if (_viewModel.state.hasNextPage &&
          !_viewModel.state.isNextPageLoading &&
          _viewModel.state.pageFailure == null) {
        unawaited(_viewModel.loadNextPage());
      }
    }
  }

  void _handleSuccess(ReassignmentResultEntity result) {
    final locale = context.localization;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(locale.reassignDriverSuccess),
        duration: const Duration(seconds: 2),
      ),
    );
    if (widget.onConfirm != null) {
      widget.onConfirm!(result);
    }
    unawaited(Navigator.of(context).maybePop(result));
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocConsumer<DispatcherReassignmentViewModel,
        DispatcherReassignmentState>(
      bloc: _viewModel,
      listenWhen: (prev, curr) =>
          prev.successResult != curr.successResult && curr.successResult != null,
      listener: (context, state) {
        if (state.successResult != null) {
          _handleSuccess(state.successResult!);
        }
      },
      builder: (context, state) {
        if (state.isInitialLoading && state.data == null) {
          return Scaffold(
            backgroundColor: color.surfaceContainerLowest,
            appBar: ReassignDriverAppBar(onBack: widget.onBack),
            body: const DispatcherReassignShimmer(),
          );
        }

        if (state.initialFailure != null && state.data == null) {
          return Scaffold(
            backgroundColor: color.surfaceContainerLowest,
            appBar: ReassignDriverAppBar(onBack: widget.onBack),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.screenH),
                  child: ApiErrorWidget(
                    exception: state.initialFailure!.exception,
                    onRetry: () => unawaited(_viewModel.retry()),
                  ),
                ),
              ),
            ),
          );
        }

        final data = state.data;
        if (data == null) {
          return Scaffold(
            backgroundColor: color.surfaceContainerLowest,
            appBar: ReassignDriverAppBar(onBack: widget.onBack),
            body: const SizedBox.shrink(),
          );
        }

        final issueDetail = widget.issue ??
            DispatcherIssueDetailEntity.fromReassignmentSummary(
              summary: data.summary,
              currentDriver: data.currentDriver,
            );

        return Scaffold(
          backgroundColor: color.surfaceContainerLowest,
          appBar: ReassignDriverAppBar(onBack: widget.onBack),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _viewModel.refresh(),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.screenH,
                  vertical: Spacing.screenV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReassignDriverIssueSummaryCard(issue: issueDetail),
                    if (state.terminalIssueConflict) ...[
                      const SizedBox(height: Spacing.sm),
                      InlineApiErrorWidget(
                        failure: state.submitFailure ??
                            Failure(
                              errorMessage:
                                  'تم حل هذه المشكلة أو إعادة تعيين سائق لها مسبقاً',
                              code: 'ISSUE_ALREADY_RESOLVED_OR_REASSIGNED',
                            ),
                      ),
                    ] else if (state.submitFailure != null) ...[
                      const SizedBox(height: Spacing.sm),
                      InlineApiErrorWidget(
                        failure: state.submitFailure!,
                        onRetry: () => unawaited(_viewModel.retry()),
                      ),
                    ],
                    const SizedBox(height: Spacing.base),
                    ReassignDriverListHeader(
                      onFilterTap: () async {
                        await DispatcherDriverFilterBottomSheet.show(context: context);
                      },
                    ),
                    const SizedBox(height: Spacing.sm),
                    if (!state.hasCandidates)
                      DispatcherReassignEmptyStateCard(
                        onRetry: () => unawaited(_viewModel.refresh()),
                      )
                    else
                      ...data.candidates.map(
                        (candidate) => Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: ReassignDriverCard(
                            candidate: candidate,
                            isSelected: state.selectedDriverId == candidate.id,
                            onSelected: () =>
                                _viewModel.selectDriver(candidate.id),
                          ),
                        ),
                      ),
                    DispatcherReassignPaginationFooter(
                      isLoading: state.isNextPageLoading,
                      failure: state.pageFailure,
                      onRetry: () => unawaited(_viewModel.loadNextPage()),
                    ),
                    const SizedBox(height: Spacing.base),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: ReassignDriverBottomButton(
            isEnabled: state.canSubmit,
            onPressed: state.canSubmit ? () => unawaited(_viewModel.submit()) : null,
          ),
        );
      },
    );
  }
}

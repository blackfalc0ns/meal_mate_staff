import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/dispatcher_support_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';
import '../../domain/entities/dispatcher_issue_workflow_result_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../../domain/usecase/get_dispatcher_issue_details_usecase.dart';
import '../../domain/usecase/resolve_dispatcher_issue_usecase.dart';
import '../manager/issue_details/dispatcher_issue_details_state.dart';
import '../manager/issue_details/dispatcher_issue_details_view_model.dart';
import '../widgets/issue_details/dispatcher_issue_details_action_buttons.dart';
import '../widgets/issue_details/dispatcher_issue_details_attachments_card.dart';
import '../widgets/issue_details/dispatcher_issue_details_description_card.dart';
import '../widgets/issue_details/dispatcher_issue_details_driver_card.dart';
import '../widgets/issue_details/dispatcher_issue_details_header_card.dart';
import '../widgets/issue_details/dispatcher_issue_details_shimmer.dart';
import '../widgets/issue_details/dispatcher_issue_details_trip_card.dart';
import '../widgets/issue_details/dispatcher_issue_resolution_card.dart';
import '../widgets/issue_details/dispatcher_resolve_issue_dialog.dart';

class DispatcherIssueDetailsScreen extends StatefulWidget {
  const DispatcherIssueDetailsScreen({
    super.key,
    this.issueId,
    this.issue,
    this.viewModel,
  });

  final String? issueId;
  final DispatcherIssueDetailEntity? issue;
  final DispatcherIssueDetailsViewModel? viewModel;

  @override
  State<DispatcherIssueDetailsScreen> createState() =>
      _DispatcherIssueDetailsScreenState();
}

class _DispatcherIssueDetailsScreenState
    extends State<DispatcherIssueDetailsScreen> {
  late final DispatcherIssueDetailsViewModel _viewModel;
  late final bool _ownsViewModel;

  String get _effectiveIssueId =>
      widget.issueId ?? widget.issue?.issueId ?? '';

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _ownsViewModel = false;
    } else if (getIt.isRegistered<DispatcherIssueDetailsViewModel>()) {
      _viewModel = getIt<DispatcherIssueDetailsViewModel>(
        param1: _effectiveIssueId,
      );
      _ownsViewModel = true;
    } else {
      _viewModel = DispatcherIssueDetailsViewModel(
        issueId: _effectiveIssueId,
        getDetailsUseCase: getIt<GetDispatcherIssueDetailsUseCase>(),
        resolveUseCase: getIt<ResolveDispatcherIssueUseCase>(),
      );
      _ownsViewModel = true;
    }

    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    final workflowResult = DispatcherIssueWorkflowResultEntity(
      changed: _viewModel.state.requiresRefresh,
      requiresRefresh: _viewModel.state.requiresRefresh,
      issueId: _effectiveIssueId,
    );
    Navigator.of(context).pop(workflowResult);
  }

  Future<void> _onAssignReplacement(
    BuildContext context,
    String issueId,
  ) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.dispatcherReassignDriver,
      arguments: DispatcherReassignDriverRouteArgs(issueId: issueId),
    );
    if (result is ReassignmentResultEntity && mounted) {
      _viewModel.applyReassignmentResult(result);
    }
  }

  void _onContactDriver(BuildContext context, String driverName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$driverName...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResolveDialog(BuildContext context) {
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocConsumer<DispatcherIssueDetailsViewModel,
            DispatcherIssueDetailsState>(
          bloc: _viewModel,
          listenWhen: (prev, curr) =>
              prev.resolveSuccessId != curr.resolveSuccessId,
          listener: (context, state) {
            Navigator.of(dialogContext).pop();
          },
          builder: (context, state) {
            return DispatcherResolveIssueDialog(
              isResolving: state.isResolving,
              resolveFailure: state.resolveFailure,
              notesError: state.resolutionNotesError,
              onResolve: (notes) => _viewModel.resolve(notes),
            );
          },
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: color.surfaceContainerLowest,
        appBar: CustomAppBar(
          title: locale.issueDetailsTitle,
          centerTitle: true,
          onBackPressed: () => _handleBack(context),
          actions: [NotificationButton(hasUnread: true, onPressed: () {})],
        ),
        body: SafeArea(
          child: BlocBuilder<DispatcherIssueDetailsViewModel,
              DispatcherIssueDetailsState>(
            bloc: _viewModel,
            builder: (context, state) {
              if (state.detail == null) {
                if (state.isInitialLoading) {
                  return const DispatcherIssueDetailsShimmer();
                }
                if (state.initialFailure != null) {
                  return Center(
                    child: ApiErrorWidget(
                      exception: state.initialFailure!.exception,
                      onRetry: () => _viewModel.retry(),
                    ),
                  );
                }
                return const DispatcherIssueDetailsShimmer();
              }

              final currentIssue = state.detail!;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base,
                  vertical: Spacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DispatcherIssueDetailsHeaderCard(issue: currentIssue),
                    const SizedBox(height: Spacing.sm),
                    DispatcherIssueDetailsDriverCard(issue: currentIssue),
                    const SizedBox(height: Spacing.sm),
                    DispatcherIssueDetailsDescriptionCard(
                      description: currentIssue.description,
                    ),
                    const SizedBox(height: Spacing.sm),
                    DispatcherIssueDetailsAttachmentsCard(
                      attachments: currentIssue.attachments,
                    ),
                    const SizedBox(height: Spacing.sm),
                    DispatcherIssueDetailsTripCard(issue: currentIssue),
                    const SizedBox(height: Spacing.sm),
                    if (currentIssue.isResolved &&
                        currentIssue.resolution != null) ...[
                      DispatcherIssueResolutionCard(
                        resolution: currentIssue.resolution!,
                      ),
                    ] else ...[
                      DispatcherIssueDetailsActionButtons(
                        canMutate: state.canMutate,
                        onAssignReplacementTap: () => _onAssignReplacement(
                          context,
                          currentIssue.issueId,
                        ),
                        onResolveTap: () => _showResolveDialog(context),
                        onContactDriverTap: () => _onContactDriver(
                          context,
                          currentIssue.driverName,
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.lg),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/assign_box_route_arguments.dart';
import '../../../../../config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../../dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import '../manager/assign_box_event.dart';
import '../manager/assign_box_state.dart';
import '../manager/assign_box_view_model.dart';
import '../widgets/assign_box_bottom_actions.dart';
import '../widgets/assign_box_driver_card.dart';
import '../widgets/assign_box_drivers_header.dart';
import '../widgets/assign_box_recommended_card.dart';
import '../widgets/assign_box_shimmer.dart';
import '../widgets/assign_box_summary_bottom_sheet.dart';
import '../widgets/assign_box_summary_card.dart';

class AssignBoxScreen extends StatefulWidget {
  const AssignBoxScreen({
    super.key,
    required this.args,
    this.viewModel,
    this.onAssignmentCompleted,
    this.onViewAllDrivers,
  });

  final AssignBoxRouteArgs args;
  final AssignBoxViewModel? viewModel;
  final ValueChanged<DriverAssignmentResultEntity>? onAssignmentCompleted;
  final ValueChanged<String>? onViewAllDrivers;

  @override
  State<AssignBoxScreen> createState() => _AssignBoxScreenState();
}

class _AssignBoxScreenState extends State<AssignBoxScreen> {
  late final AssignBoxViewModel _viewModel;
  late final bool _isInternalViewModel;
  int _lastSeenNoticeId = 0;
  int _lastSeenSuccessId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else {
      _viewModel = getIt<AssignBoxViewModel>(param1: widget.args.boxId);
      _isInternalViewModel = true;
    }

    _lastSeenNoticeId = _viewModel.state.noticeId;
    _lastSeenSuccessId = _viewModel.state.successId;

    if (_viewModel.state.details == null &&
        !_viewModel.state.isInitialLoading) {
      unawaited(_viewModel.doIntent(const LoadAssignBoxEvent()));
    }
  }

  @override
  void dispose() {
    if (_isInternalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  Future<void> _handleViewAllDrivers(String boxId, String zoneName) async {
    if (widget.onViewAllDrivers != null) {
      widget.onViewAllDrivers!(boxId);
      return;
    }

    final result = await context.pushNamed<dynamic>(
      AppRoutes.dispatcherDrivers,
      arguments: DispatcherDriversRouteArgs.assignment(
        boxId: boxId,
        initialAreaName: zoneName,
      ),
    );

    if (!mounted) return;
    if (result is DriverAssignmentResultEntity || result == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<AssignBoxViewModel, AssignBoxState>(
        listener: (context, state) {
          if (state.successId > _lastSeenSuccessId) {
            _lastSeenSuccessId = state.successId;
            if (widget.onAssignmentCompleted != null &&
                state.assignmentResult != null) {
              widget.onAssignmentCompleted!(state.assignmentResult!);
            }
            final msg =
                state.assignmentResult?.message ??
                context.localization.assignBoxSuccessMessage;
            CustomSnackbar.showSuccess(context: context, message: msg);
            Navigator.of(context).pop(true);
            return;
          }

          if (state.noticeId > _lastSeenNoticeId) {
            _lastSeenNoticeId = state.noticeId;
            final errorMsg =
                state.submitFailure?.errorMessage ??
                state.refreshFailure?.errorMessage;
            if (errorMsg != null && errorMsg.isNotEmpty) {
              CustomSnackbar.showError(context: context, message: errorMsg);
            }
            unawaited(_viewModel.doIntent(const ClearAssignBoxNoticeEvent()));
          }
        },
        builder: (context, state) {
          final color = context.colorScheme;
          final locale = context.localization;

          final title = state.details != null
              ? locale.assignBoxTitle(state.details!.box.boxCode)
              : locale.assignBoxTitle('');

          Widget body;
          if (state.details == null && state.isInitialLoading) {
            body = const AssignBoxShimmer();
          } else if (state.details == null && state.initialFailure != null) {
            body = Center(
              child: ApiErrorWidget.fromTypedFailure(
                failure: state.initialFailure!,
                onRetry: () =>
                    _viewModel.doIntent(const RetryAssignBoxDetailsEvent()),
              ),
            );
          } else if (state.details != null) {
            body = RefreshIndicator(
              onRefresh: () =>
                  _viewModel.doIntent(const RefreshAssignBoxDetailsEvent()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.screenH,
                  vertical: Spacing.screenV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AssignBoxSummaryCard(order: state.details!.box),
                    if (state.details!.bestSuggestion != null) ...[
                      const SizedBox(height: Spacing.base),
                      AssignBoxRecommendedCard(
                        driver: state.details!.bestSuggestion!,
                        isSelected:
                            state.selectedDriverId ==
                            state.details!.bestSuggestion!.driverId,
                        onSelected: () => _viewModel.doIntent(
                          SelectAssignBoxDriverEvent(
                            state.details!.bestSuggestion!.driverId,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.lg),
                    AssignBoxDriversHeader(
                      onViewAllPressed: () => _handleViewAllDrivers(
                        state.details!.box.boxId,
                        state.details!.box.zoneName,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    ...state.details!.candidates.map(
                      (candidate) => Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: AssignBoxDriverCard(
                          driver: candidate,
                          isSelected:
                              state.selectedDriverId == candidate.driverId,
                          onSelected: () => _viewModel.doIntent(
                            SelectAssignBoxDriverEvent(candidate.driverId),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.base),
                  ],
                ),
              ),
            );
          } else {
            body = const AssignBoxShimmer();
          }

          return Scaffold(
            backgroundColor: color.surface,
            appBar: CustomAppBar(
              title: title,
              showBackButton: true,
              onBackPressed: () => Navigator.of(context).maybePop(),
              actions: [NotificationButton(hasUnread: false, onPressed: () {})],
            ),
            body: body,
            bottomNavigationBar: state.details != null
                ? AssignBoxBottomActions(
                    isConfirmEnabled: state.canSubmit,
                    isSubmitting: state.isSubmitting,
                    onViewBoxPressed: () => AssignBoxSummaryBottomSheet.show(
                      context: context,
                      viewModel: _viewModel,
                    ),
                    onConfirmPressed: () => _viewModel.doIntent(
                      SubmitAssignBoxEvent(
                        localizedNotes: locale.assignBoxFastAssignNotes(
                          state.details!.box.boxCode,
                        ),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

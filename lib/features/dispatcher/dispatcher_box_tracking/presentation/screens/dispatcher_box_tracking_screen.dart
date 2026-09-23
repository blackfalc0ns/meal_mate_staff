import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../manager/box_tracking_event.dart';
import '../manager/box_tracking_state.dart';
import '../manager/box_tracking_view_model.dart';
import '../widgets/box_tracking_app_bar.dart';
import '../widgets/box_tracking_details_card.dart';
import '../widgets/box_tracking_driver_card.dart';
import '../widgets/box_tracking_header_card.dart';
import '../widgets/box_tracking_report_issue_button.dart';
import '../widgets/box_tracking_report_issue_sheet.dart';
import '../widgets/box_tracking_shimmer.dart';
import '../widgets/box_tracking_timeline_card.dart';

class DispatcherBoxTrackingScreen extends StatefulWidget {
  const DispatcherBoxTrackingScreen({
    super.key,
    required this.boxId,
    this.viewModel,
    this.onBack,
    this.onMore,
    this.onLiveTracking,
    this.onSendMessage,
    this.onCall,
    this.onReportIssue,
  });

  final String boxId;
  final BoxTrackingViewModel? viewModel;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final VoidCallback? onLiveTracking;
  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;
  final VoidCallback? onReportIssue;

  @override
  State<DispatcherBoxTrackingScreen> createState() =>
      _DispatcherBoxTrackingScreenState();
}

class _DispatcherBoxTrackingScreenState
    extends State<DispatcherBoxTrackingScreen> {
  late final BoxTrackingViewModel _viewModel;
  late final bool _isInternalViewModel;
  int _lastSeenNoticeId = 0;
  int _lastSeenReportNoticeId = 0;

  @override
  void initState() {
    super.initState();
    _isInternalViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? getIt<BoxTrackingViewModel>(param1: widget.boxId);
    _lastSeenNoticeId = _viewModel.state.noticeId;
    _lastSeenReportNoticeId = _viewModel.state.reportNoticeId;
    unawaited(_viewModel.doIntent(const LoadBoxTrackingEvent()));
  }

  @override
  void dispose() {
    if (_isInternalViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<BoxTrackingViewModel, BoxTrackingState>(
        listenWhen: (previous, current) =>
            current.noticeId != _lastSeenNoticeId ||
            current.reportNoticeId != _lastSeenReportNoticeId,
        listener: (context, state) {
          if (state.noticeId != _lastSeenNoticeId) {
            _lastSeenNoticeId = state.noticeId;
            if (state.nonFatalFailure != null) {
              CustomSnackbar.showError(
                context: context,
                message: state.nonFatalFailure!.errorMessage,
              );
            }
          }

          if (state.reportNoticeId != _lastSeenReportNoticeId) {
            _lastSeenReportNoticeId = state.reportNoticeId;
            if (state.reportSuccessMessage != null) {
              CustomSnackbar.showSuccess(
                context: context,
                message: state.reportSuccessMessage!,
              );
            } else if (state.reportFailure != null) {
              CustomSnackbar.showError(
                context: context,
                message: state.reportFailure!.errorMessage,
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: BoxTrackingAppBar(
              onBack: widget.onBack,
              onMore: widget.onMore,
            ),
            body: SafeArea(child: _buildBody(context, state)),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BoxTrackingState state) {
    if (state.isInitialLoading) {
      return const BoxTrackingShimmer();
    }

    if (state.initialFailure != null) {
      return Center(
        child: SingleChildScrollView(
          child: ApiErrorWidget.fromTypedFailure(
            failure: state.initialFailure!,
            onRetry: () => _viewModel.doIntent(const RetryBoxTrackingEvent()),
          ),
        ),
      );
    }

    final box = state.tracking;
    if (box == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.doIntent(const RefreshBoxTrackingEvent()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenH,
          vertical: Spacing.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BoxTrackingHeaderCard(box: box),
            const SizedBox(height: Spacing.md),
            BoxTrackingTimelineCard(steps: box.steps),
            const SizedBox(height: Spacing.md),
            BoxTrackingDriverCard(
              driver: box.driver,
              onLiveTracking: widget.onLiveTracking,
              onSendMessage: widget.onSendMessage,
              onCall: widget.onCall,
            ),
            const SizedBox(height: Spacing.md),
            BoxTrackingDetailsCard(box: box),
            const SizedBox(height: Spacing.lg),
            BoxTrackingReportIssueButton(
              onPressed:
                  widget.onReportIssue ??
                  () => BoxTrackingReportIssueSheet.show(
                    context: context,
                    viewModel: _viewModel,
                  ),
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}

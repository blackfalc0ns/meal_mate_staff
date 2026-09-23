import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_bottom_sheet.dart';
import '../manager/assign_box_event.dart';
import '../manager/assign_box_state.dart';
import '../manager/assign_box_view_model.dart';
import 'assign_box_summary_content.dart';
import 'assign_box_summary_shimmer.dart';

class AssignBoxSummaryBottomSheet extends StatelessWidget {
  const AssignBoxSummaryBottomSheet({super.key, required this.viewModel});

  final AssignBoxViewModel viewModel;

  static Future<void> show({
    required BuildContext context,
    required AssignBoxViewModel viewModel,
  }) {
    // If not cached, trigger load
    if (viewModel.state.summary == null && !viewModel.state.isSummaryLoading) {
      viewModel.doIntent(const LoadAssignBoxSummaryEvent());
    }

    return CustomBottomSheet.show<void>(
      context: context,
      title: context.localization.assignBoxSummaryTitle,
      showDragHandle: true,
      maxHeightFactor: 0.85,
      child: BlocProvider.value(
        value: viewModel,
        child: AssignBoxSummaryBottomSheet(viewModel: viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignBoxViewModel, AssignBoxState>(
      buildWhen: (previous, current) =>
          previous.summary != current.summary ||
          previous.isSummaryLoading != current.isSummaryLoading ||
          previous.summaryFailure != current.summaryFailure,
      builder: (context, state) {
        if (state.summary != null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            child: AssignBoxSummaryContent(summary: state.summary!),
          );
        }

        if (state.summaryFailure != null) {
          return Padding(
            padding: const EdgeInsets.all(Spacing.base),
            child: InlineApiErrorWidget(
              failure: state.summaryFailure!,
              onRetry: () => viewModel.doIntent(const RetryAssignBoxSummaryEvent()),
            ),
          );
        }

        return const AssignBoxSummaryShimmer();
      },
    );
  }
}

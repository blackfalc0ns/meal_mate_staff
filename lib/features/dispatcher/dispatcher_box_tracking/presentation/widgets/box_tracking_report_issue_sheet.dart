import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../../../../core/widget/custom_bottom_sheet.dart';
import '../../domain/entities/box_issue_type.dart';
import '../manager/box_tracking_event.dart';
import '../manager/box_tracking_state.dart';
import '../manager/box_tracking_view_model.dart';

class BoxTrackingReportIssueSheet extends StatefulWidget {
  const BoxTrackingReportIssueSheet({super.key, required this.viewModel});

  final BoxTrackingViewModel viewModel;

  static Future<void> show({
    required BuildContext context,
    required BoxTrackingViewModel viewModel,
  }) {
    return CustomBottomSheet.show<void>(
      context: context,
      title: context.localization.boxTrackingReportIssueTitle,
      showDragHandle: true,
      maxHeightFactor: 0.85,
      child: BlocProvider.value(
        value: viewModel,
        child: BoxTrackingReportIssueSheet(viewModel: viewModel),
      ),
    );
  }

  @override
  State<BoxTrackingReportIssueSheet> createState() =>
      _BoxTrackingReportIssueSheetState();
}

class _BoxTrackingReportIssueSheetState
    extends State<BoxTrackingReportIssueSheet> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.viewModel.state.issueDescription,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return BlocConsumer<BoxTrackingViewModel, BoxTrackingState>(
      bloc: widget.viewModel,
      listenWhen: (previous, current) =>
          previous.reportSuccessMessage != current.reportSuccessMessage &&
          current.reportSuccessMessage != null,
      listener: (context, state) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        // Sync controller if state was reset
        if (state.issueDescription.isEmpty &&
            _descriptionController.text.isNotEmpty) {
          _descriptionController.clear();
        }

        final isValid = state.issueDescription.trim().isNotEmpty;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: Spacing.screenH,
            right: Spacing.screenH,
            top: Spacing.sm,
            bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Issue Types Section
              Text(
                locale.boxTrackingReportIssue,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size14,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  _buildIssueChip(
                    context: context,
                    type: BoxIssueType.damagedBox,
                    label: locale.boxTrackingIssueTypeDamaged,
                    isSelected:
                        state.selectedIssueType == BoxIssueType.damagedBox,
                    color: color,
                  ),
                  _buildIssueChip(
                    context: context,
                    type: BoxIssueType.delayedDelivery,
                    label: locale.boxTrackingIssueTypeLateDelivery,
                    isSelected:
                        state.selectedIssueType == BoxIssueType.delayedDelivery,
                    color: color,
                  ),
                  _buildIssueChip(
                    context: context,
                    type: BoxIssueType.wrongAddress,
                    label: locale.boxTrackingIssueTypeWrongAddress,
                    isSelected:
                        state.selectedIssueType == BoxIssueType.wrongAddress,
                    color: color,
                  ),
                  _buildIssueChip(
                    context: context,
                    type: BoxIssueType.customerUnreachable,
                    label: locale.boxTrackingIssueTypeCustomerUnavailable,
                    isSelected:
                        state.selectedIssueType ==
                        BoxIssueType.customerUnreachable,
                    color: color,
                  ),
                  _buildIssueChip(
                    context: context,
                    type: BoxIssueType.other,
                    label: locale.boxTrackingIssueTypeOther,
                    isSelected: state.selectedIssueType == BoxIssueType.other,
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 2. Issue Description TextField
              Text(
                locale.boxTrackingIssueNotesLabel,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size14,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                minLines: 3,
                style: getRegularStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size14,
                ),
                decoration: InputDecoration(
                  hintText: locale.boxTrackingIssueNotesHint,
                  hintStyle: getRegularStyle(
                    color: color.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: FontSize.size13,
                  ),
                  filled: true,
                  fillColor: color.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    borderSide: BorderSide(
                      color: color.outlineVariant,
                      width: Spacing.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    borderSide: BorderSide(
                      color: color.outlineVariant,
                      width: Spacing.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    borderSide: BorderSide(
                      color: color.primary,
                      width: Spacing.border * 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(Spacing.md),
                ),
                onChanged: (value) {
                  unawaited(
                    widget.viewModel.doIntent(
                      ChangeBoxIssueDescriptionEvent(value),
                    ),
                  );
                },
              ),
              const SizedBox(height: Spacing.xl),

              // 3. Submit Button
              AppButton(
                key: const Key('box_tracking_report_submit_button'),
                text: state.isSubmittingIssue
                    ? locale.boxTrackingIssueSubmitting
                    : locale.boxTrackingIssueSubmit,
                isLoading: state.isSubmittingIssue,
                color: AppColors.error,
                onPressed: (!isValid || state.isSubmittingIssue)
                    ? null
                    : () {
                        unawaited(
                          widget.viewModel.doIntent(
                            const SubmitBoxIssueEvent(),
                          ),
                        );
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIssueChip({
    required BuildContext context,
    required BoxIssueType type,
    required String label,
    required bool isSelected,
    required ColorScheme color,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: isSelected
          ? getSemiBoldStyle(color: color.onError, fontSize: FontSize.size12)
          : getRegularStyle(color: color.onSurface, fontSize: FontSize.size12),
      selectedColor: color.error,
      backgroundColor: color.surface,
      side: BorderSide(
        color: isSelected ? color.error : color.outlineVariant,
        width: Spacing.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      onSelected: (_) {
        unawaited(widget.viewModel.doIntent(ChangeBoxIssueTypeEvent(type)));
      },
    );
  }
}

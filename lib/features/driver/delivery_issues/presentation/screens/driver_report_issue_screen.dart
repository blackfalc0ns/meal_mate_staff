import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/delivery_issue_entity.dart';
import '../../domain/entities/delivery_issue_reason.dart';
import '../../domain/fake_data/delivery_issues_fake_data.dart';
import '../widgets/delivery_issue_action_buttons.dart';
import '../widgets/delivery_issue_box_summary_card.dart';
import '../widgets/delivery_issue_header.dart';
import '../widgets/delivery_issue_notes_field.dart';
import '../widgets/delivery_issue_notice_banner.dart';
import '../widgets/delivery_issue_photo_picker.dart';
import '../widgets/delivery_issue_reason_selector.dart';

class DriverReportIssueScreen extends StatefulWidget {
  const DriverReportIssueScreen({
    super.key,
    this.initialIssue,
    this.onSubmitReport,
    this.onRequestReassign,
    this.onCallSupervisor,
    this.onBackPressed,
  });

  final DeliveryIssueEntity? initialIssue;
  final ValueChanged<DeliveryIssueEntity>? onSubmitReport;
  final VoidCallback? onRequestReassign;
  final VoidCallback? onCallSupervisor;
  final VoidCallback? onBackPressed;

  @override
  State<DriverReportIssueScreen> createState() =>
      _DriverReportIssueScreenState();
}

class _DriverReportIssueScreenState extends State<DriverReportIssueScreen> {
  late final DeliveryIssueEntity _issue;
  late final ValueNotifier<DeliveryIssueReason> _reasonNotifier;
  late final ValueNotifier<List<String>> _photosNotifier;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _issue = widget.initialIssue ?? DeliveryIssuesFakeData.defaultIssue;
    _reasonNotifier = ValueNotifier(_issue.selectedReason);
    _photosNotifier = ValueNotifier(List<String>.from(_issue.attachedPhotos));
    _notesController = TextEditingController(text: _issue.notes);
  }

  @override
  void dispose() {
    _reasonNotifier.dispose();
    _photosNotifier.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final updatedIssue = _issue.copyWith(
      selectedReason: _reasonNotifier.value,
      notes: _notesController.text.trim(),
      attachedPhotos: _photosNotifier.value,
    );

    if (widget.onSubmitReport != null) {
      widget.onSubmitReport!(updatedIssue);
      return;
    }

    unawaited(
      context.pushReplacementNamed(
        AppRoutes.driverIssueSubmitted,
        arguments: updatedIssue,
      ),
    );
  }

  void _handleRequestReassign() {
    if (widget.onRequestReassign != null) {
      widget.onRequestReassign!();
      return;
    }

    unawaited(
      context.pushNamed(
        AppRoutes.driverReassignmentRequest,
        arguments: _issue,
      ),
    );
  }

  void _handleCallSupervisor() {
    if (widget.onCallSupervisor != null) {
      widget.onCallSupervisor!();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.localization.reportIssueCallSupervisor),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleAddPhoto() {
    final current = _photosNotifier.value;
    if (current.length < 4) {
      _photosNotifier.value = [
        ...current,
        DeliveryIssuesFakeData.defaultPhotos.first,
      ];
    }
  }

  void _handleRemovePhoto(int index) {
    final current = List<String>.from(_photosNotifier.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      _photosNotifier.value = current;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DeliveryIssueHeader(
        onBackPressed: widget.onBackPressed ?? () => context.maybePopRoute(),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenH,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DeliveryIssueBoxSummaryCard(issue: _issue),
              const SizedBox(height: Spacing.base),
              ValueListenableBuilder<DeliveryIssueReason>(
                valueListenable: _reasonNotifier,
                builder: (context, selectedReason, _) {
                  return DeliveryIssueReasonSelector(
                    selectedReason: selectedReason,
                    onReasonSelected: (reason) {
                      _reasonNotifier.value = reason;
                    },
                  );
                },
              ),
              const SizedBox(height: Spacing.base),
              DeliveryIssueNotesField(controller: _notesController),
              const SizedBox(height: Spacing.base),
              ValueListenableBuilder<List<String>>(
                valueListenable: _photosNotifier,
                builder: (context, photos, _) {
                  return DeliveryIssuePhotoPicker(
                    photos: photos,
                    onAddPhoto: _handleAddPhoto,
                    onRemovePhoto: _handleRemovePhoto,
                  );
                },
              ),
              const SizedBox(height: Spacing.lg),
              DeliveryIssueActionButtons(
                onSubmit: _handleSubmit,
                onRequestReassign: _handleRequestReassign,
                onCallSupervisor: _handleCallSupervisor,
              ),
              const SizedBox(height: Spacing.md),
              const DeliveryIssueNoticeBanner(),
              const SizedBox(height: Spacing.screenV),
            ],
          ),
        ),
      ),
    );
  }
}

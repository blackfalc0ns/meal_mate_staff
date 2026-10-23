import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../config/routing/arguments/driver_reassignment_route_arguments.dart';
import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/helpers/image_picker_helper.dart';
import '../../../../../core/network/failures.dart';
import '../../domain/entities/delivery_issue_entity.dart';
import '../../domain/entities/delivery_issue_reason.dart';
import '../../domain/entities/issue_photo_item.dart';
import '../../domain/fake_data/delivery_issues_fake_data.dart';
import '../manager/driver_issue_event.dart';
import '../manager/driver_issue_state.dart';
import '../manager/driver_issue_view_model.dart';
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
    this.viewModel,
    this.imagePicker,
  });

  final DeliveryIssueEntity? initialIssue;
  final ValueChanged<DeliveryIssueEntity>? onSubmitReport;
  final VoidCallback? onRequestReassign;
  final VoidCallback? onCallSupervisor;
  final VoidCallback? onBackPressed;
  final DriverIssueViewModel? viewModel;
  final ImagePicker? imagePicker;

  @override
  State<DriverReportIssueScreen> createState() =>
      _DriverReportIssueScreenState();
}

class _DriverReportIssueScreenState extends State<DriverReportIssueScreen> {
  late final DeliveryIssueEntity _issue;
  late final ValueNotifier<DeliveryIssueReason> _reasonNotifier;
  late final ValueNotifier<List<String>> _photosNotifier;
  late final TextEditingController _notesController;
  late final DriverIssueViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _issue = widget.initialIssue ?? DeliveryIssuesFakeData.defaultIssue;
    _reasonNotifier = ValueNotifier(_issue.selectedReason);
    _photosNotifier = ValueNotifier(List<String>.from(_issue.attachedPhotos));
    _notesController = TextEditingController(text: _issue.notes);

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
    } else if (getIt.isRegistered<DriverIssueViewModel>()) {
      _viewModel = getIt<DriverIssueViewModel>(param1: _issue);
    } else {
      _viewModel = null;
    }
  }

  @override
  void dispose() {
    _reasonNotifier.dispose();
    _photosNotifier.dispose();
    _notesController.dispose();
    if (widget.viewModel == null && _viewModel != null) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _handleSubmit() {
    if (_viewModel != null && _viewModel.state.isLoading) {
      return;
    }
    if (_viewModel != null && _viewModel.state.hasUploadingPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.localization.reportIssuePhotoUploadWait),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final updatedIssue = _issue.copyWith(
      selectedReason: _reasonNotifier.value,
      notes: _notesController.text.trim(),
      attachedPhotos: _viewModel != null
          ? _viewModel.state.photos
          : _photosNotifier.value,
    );

    if (widget.onSubmitReport != null) {
      widget.onSubmitReport!(updatedIssue);
      return;
    }

    if (_viewModel != null) {
      final boxId =
          _issue.deliveryContext?.boxId ??
          _issue.boxCode.replaceAll('#', '').trim();
      _viewModel.add(
        UpdateDeliveryIssueNotesEvent(_notesController.text.trim()),
      );
      _viewModel.add(SelectDeliveryIssueReasonEvent(_reasonNotifier.value));
      _viewModel.add(
        SubmitDriverIssueEvent(
          boxId: boxId,
          selectedPhotoCount: _photosNotifier.value
              .where((path) => !path.startsWith('assets/'))
              .length,
        ),
      );
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

    final contextEntity = _issue.deliveryContext;
    if (contextEntity == null || !contextEntity.isPickedUp) {
      return;
    }

    unawaited(
      context.pushNamed(
        AppRoutes.driverReassignmentRequest,
        arguments: DriverReassignmentRouteArguments(delivery: contextEntity),
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

  Future<void> _handleAddPhoto() async {
    final currentCount = _viewModel != null
        ? _viewModel.state.photoItems.length
        : _photosNotifier.value.length;
    if (currentCount >= 3) {
      return;
    }

    final file = await ImagePickerHelper.pickImageWithSourceSheet(
      context,
      picker: widget.imagePicker,
      title: context.localization.reportIssueAddPhoto,
    );

    if (file == null || !mounted) {
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[IssueEvidence v2] selected hasViewModel=${_viewModel != null}',
      );
    }
    final updated = [..._photosNotifier.value, file.path];
    _photosNotifier.value = updated;

    if (_viewModel != null) {
      final item = IssuePhotoItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${_viewModel.state.photoItems.length}',
        localPath: file.path,
        status: IssuePhotoStatus.uploading,
      );
      _viewModel.add(AddIssuePhotoItemEvent(item));
    }
  }

  void _handleRemovePhoto(int index) {
    if (_viewModel != null && index < _viewModel.state.photoItems.length) {
      final item = _viewModel.state.photoItems[index];
      _viewModel.add(RemoveIssuePhotoItemEvent(item.id));
    }
    final current = List<String>.from(_photosNotifier.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      _photosNotifier.value = current;
      if (_viewModel == null) {
        _viewModel?.add(RemoveDeliveryIssuePhotoEvent(index));
      }
    }
  }

  void _handleRetryPhoto(IssuePhotoItem item) {
    _viewModel?.add(RetryIssuePhotoUploadEvent(item.id));
  }

  Widget _buildContent(BuildContext context, {DriverIssueState? issueState}) {
    final color = context.colorScheme;
    final locale = context.localization;

    final isLoading = issueState?.isLoading ?? false;
    final hasUploadingPhotos = issueState?.hasUploadingPhotos ?? false;
    final errorMessage = issueState?.errorMessage;

    return SingleChildScrollView(
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
                  _viewModel?.add(SelectDeliveryIssueReasonEvent(reason));
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
                photoItems: issueState?.photoItems,
                maxPhotos: 3,
                onAddPhoto: _handleAddPhoto,
                onRemovePhoto: _handleRemovePhoto,
                onRetryPhoto: _handleRetryPhoto,
              );
            },
          ),
          if (hasUploadingPhotos) ...[
            const SizedBox(height: Spacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color.primary),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.reportIssuePhotoUploading,
                  style: getRegularStyle(
                    fontSize: FontSize.size12,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Spacing.lg),
          if (errorMessage != null && errorMessage.isNotEmpty) ...[
            InlineApiErrorWidget(failure: Failure(errorMessage: errorMessage)),
            const SizedBox(height: Spacing.md),
          ],
          DeliveryIssueActionButtons(
            onSubmit: hasUploadingPhotos ? null : _handleSubmit,
            isLoading: isLoading,
            onRequestReassign:
                widget.onRequestReassign ??
                ((_issue.deliveryContext != null &&
                        _issue.deliveryContext!.isPickedUp)
                    ? _handleRequestReassign
                    : null),
            onCallSupervisor: _handleCallSupervisor,
          ),
          const SizedBox(height: Spacing.md),
          const DeliveryIssueNoticeBanner(),
          const SizedBox(height: Spacing.screenV),
        ],
      ),
    );
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
        child: _viewModel != null
            ? BlocConsumer<DriverIssueViewModel, DriverIssueState>(
                bloc: _viewModel,
                listener: (context, state) {
                  if (state.status == DriverIssueStatus.success) {
                    unawaited(
                      context.pushReplacementNamed(
                        AppRoutes.driverIssueSubmitted,
                        arguments: state.toEntity(),
                      ),
                    );
                  }
                },
                builder: (context, state) =>
                    _buildContent(context, issueState: state),
              )
            : _buildContent(context),
      ),
    );
  }
}

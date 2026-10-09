import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/driver_reassignment_route_arguments.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/reassignment_delivery_context_entity.dart';
import '../../domain/entities/reassignment_reason.dart';
import '../../domain/entities/reassignment_request_entity.dart';
import '../manager/driver_reassignment_event.dart';
import '../manager/driver_reassignment_state.dart';
import '../manager/driver_reassignment_view_model.dart';
import '../widgets/reassignment_hero_illustration.dart';
import '../widgets/reassignment_notes_field.dart';
import '../widgets/reassignment_reason_dropdown.dart';
import '../widgets/reassignment_request_header.dart';
import '../widgets/reassignment_submission_shimmer.dart';
import '../widgets/reassignment_submit_button.dart';

class DriverReassignmentRequestScreen extends StatefulWidget {
  const DriverReassignmentRequestScreen({
    super.key,
    this.routeArguments,
    this.deliveryContext,
    this.initialRequest,
    this.onSubmitRequest,
    this.onBackPressed,
    this.viewModel,
  });

  final DriverReassignmentRouteArguments? routeArguments;
  final ReassignmentDeliveryContextEntity? deliveryContext;
  final ReassignmentRequestEntity? initialRequest;
  final ValueChanged<ReassignmentRequestEntity>? onSubmitRequest;
  final VoidCallback? onBackPressed;
  final DriverReassignmentViewModel? viewModel;

  @override
  State<DriverReassignmentRequestScreen> createState() =>
      _DriverReassignmentRequestScreenState();
}

class _DriverReassignmentRequestScreenState
    extends State<DriverReassignmentRequestScreen> {
  late final ValueNotifier<ReassignmentReason?> _reasonNotifier;
  late final TextEditingController _notesController;
  late final DriverReassignmentViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRequest;
    _reasonNotifier = ValueNotifier<ReassignmentReason?>(initial?.reason);
    _notesController = TextEditingController(text: initial?.notes ?? '');

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
    } else if (getIt.isRegistered<DriverReassignmentViewModel>()) {
      _viewModel = getIt<DriverReassignmentViewModel>();
    } else {
      _viewModel = null;
    }
  }

  @override
  void dispose() {
    _reasonNotifier.dispose();
    _notesController.dispose();
    if (widget.viewModel == null && _viewModel != null) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _handleSubmit() {
    final selectedReason = _reasonNotifier.value;
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.localization.reassignRequestReasonHint),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final resolvedContext =
        widget.routeArguments?.delivery ?? widget.deliveryContext;

    final entity = ReassignmentRequestEntity(
      reason: selectedReason,
      notes: _notesController.text.trim(),
      latitude: resolvedContext?.driverLatitude,
      longitude: resolvedContext?.driverLongitude,
    );

    if (widget.onSubmitRequest != null) {
      widget.onSubmitRequest!(entity);
      return;
    }

    if (resolvedContext == null ||
        resolvedContext.boxId.isEmpty ||
        !resolvedContext.isPickedUp) {
      return;
    }

    if (_viewModel != null) {
      _viewModel.doIntent(
        SubmitDriverReassignmentEvent(
          boxId: resolvedContext.boxId,
          request: entity,
        ),
      );
    }
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isSubmitting,
    required bool isBlocked,
    required DriverReassignmentState state,
  }) {
    final color = context.colorScheme;
    final locale = context.localization;

    final resolvedContext =
        widget.routeArguments?.delivery ?? widget.deliveryContext;
    final hasValidContext = resolvedContext != null &&
        resolvedContext.boxId.isNotEmpty &&
        resolvedContext.isPickedUp;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ReassignmentHeroIllustration(),
          const SizedBox(height: Spacing.xl),
          if (!hasValidContext && widget.onSubmitRequest == null) ...[
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: color.errorContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
                border: Border.all(color: color.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: color.error),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      locale.reassignUnavailableContext,
                      style: getMediumStyle(
                        fontSize: FontSize.size14,
                        color: color.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],
          if (state.failure != null) ...[
            if (state.isAlreadyActiveConflict) ...[
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: color.errorContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Spacing.radiusLg),
                  border: Border.all(color: color.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: color.error),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        locale.reassignRequestAlreadyActive,
                        style: getMediumStyle(
                          fontSize: FontSize.size14,
                          color: color.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
            ] else if (state.isStopStateNotAllowed) ...[
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: color.errorContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Spacing.radiusLg),
                  border: Border.all(color: color.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: color.error),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        locale.reassignStopStateNotAllowed,
                        style: getMediumStyle(
                          fontSize: FontSize.size14,
                          color: color.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
            ] else ...[
              if (state.failure?.code == 'connectionTimeout' ||
                  state.failure?.code == 'sendTimeout' ||
                  state.failure?.code == 'receiveTimeout' ||
                  state.failure?.code == 'requestTimeout' ||
                  state.failure?.code == 'gatewayTimeout') ...[
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: color.errorContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Spacing.radiusLg),
                    border: Border.all(color: color.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: color.error),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          locale.reassignTimeoutUncertain,
                          style: getMediumStyle(
                            fontSize: FontSize.size14,
                            color: color.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],
              InlineApiErrorWidget(
                failure: state.failure!,
                onRetry: !isBlocked ? _handleSubmit : null,
              ),
              const SizedBox(height: Spacing.md),
            ],
          ],
          IgnorePointer(
            ignoring: isSubmitting || isBlocked,
            child: ValueListenableBuilder<ReassignmentReason?>(
              valueListenable: _reasonNotifier,
              builder: (context, reason, _) {
                return ReassignmentReasonDropdown(
                  selectedReason: reason,
                  onChanged: (newReason) {
                    _reasonNotifier.value = newReason;
                  },
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.md),
          IgnorePointer(
            ignoring: isSubmitting || isBlocked,
            child: ReassignmentNotesField(controller: _notesController),
          ),
          const SizedBox(height: Spacing.xl),
          ValueListenableBuilder<ReassignmentReason?>(
            valueListenable: _reasonNotifier,
            builder: (context, reason, _) {
              final canSubmit =
                  (hasValidContext || widget.onSubmitRequest != null) &&
                      reason != null;
              if (isSubmitting) {
                return const ReassignmentSubmissionShimmer();
              }
              return ReassignmentSubmitButton(
                onPressed: canSubmit && !isBlocked ? _handleSubmit : null,
              );
            },
          ),
          const SizedBox(height: Spacing.xs),
          TextButton(
            onPressed: widget.onBackPressed ?? () => context.maybePopRoute(),
            style: TextButton.styleFrom(
              foregroundColor: color.primary,
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            ),
            child: Text(
              locale.reassignRequestCancel,
              style: getBoldStyle(
                fontSize: FontSize.size16,
                color: color.primary,
              ),
            ),
          ),
          const SizedBox(height: Spacing.screenV),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final scaffold = Scaffold(
      backgroundColor: color.surface,
      appBar: ReassignmentRequestHeader(
        onBackPressed: widget.onBackPressed ?? () => context.maybePopRoute(),
      ),
      body: SafeArea(
        top: false,
        child: _viewModel != null
            ? BlocConsumer<DriverReassignmentViewModel, DriverReassignmentState>(
                bloc: _viewModel,
                listenWhen: (previous, current) =>
                    previous.status != current.status &&
                    current.isSuccess &&
                    current.result != null,
                listener: (context, state) {
                  if (!mounted) return;
                  unawaited(
                    context.pushReplacementNamed(
                      AppRoutes.driverReassignmentSubmitted,
                      arguments: state.result,
                    ),
                  );
                },
                builder: (context, state) {
                  return _buildContent(
                    context,
                    isSubmitting: state.isSubmitting,
                    isBlocked: state.isBlocked,
                    state: state,
                  );
                },
              )
            : _buildContent(
                context,
                isSubmitting: false,
                isBlocked: false,
                state: const DriverReassignmentState(),
              ),
      ),
    );

    if (_viewModel != null) {
      return BlocProvider<DriverReassignmentViewModel>.value(
        value: _viewModel,
        child: scaffold,
      );
    }

    return scaffold;
  }
}

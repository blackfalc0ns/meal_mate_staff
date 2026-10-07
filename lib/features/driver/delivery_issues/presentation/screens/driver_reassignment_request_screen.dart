import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/reassignment_reason.dart';
import '../../domain/entities/reassignment_request_entity.dart';
import '../widgets/reassignment_hero_illustration.dart';
import '../widgets/reassignment_notes_field.dart';
import '../widgets/reassignment_reason_dropdown.dart';
import '../widgets/reassignment_request_header.dart';
import '../widgets/reassignment_submit_button.dart';

class DriverReassignmentRequestScreen extends StatefulWidget {
  const DriverReassignmentRequestScreen({
    super.key,
    this.initialRequest,
    this.onSubmitRequest,
    this.onBackPressed,
  });

  final ReassignmentRequestEntity? initialRequest;
  final ValueChanged<ReassignmentRequestEntity>? onSubmitRequest;
  final VoidCallback? onBackPressed;

  @override
  State<DriverReassignmentRequestScreen> createState() =>
      _DriverReassignmentRequestScreenState();
}

class _DriverReassignmentRequestScreenState
    extends State<DriverReassignmentRequestScreen> {
  late final ValueNotifier<ReassignmentReason?> _reasonNotifier;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRequest;
    _reasonNotifier = ValueNotifier<ReassignmentReason?>(initial?.reason);
    _notesController = TextEditingController(text: initial?.notes ?? '');
  }

  @override
  void dispose() {
    _reasonNotifier.dispose();
    _notesController.dispose();
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

    final entity = ReassignmentRequestEntity(
      reason: selectedReason,
      notes: _notesController.text.trim(),
    );

    if (widget.onSubmitRequest != null) {
      widget.onSubmitRequest!(entity);
      return;
    }

    unawaited(
      context.pushReplacementNamed(
        AppRoutes.driverReassignmentSubmitted,
        arguments: entity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: ReassignmentRequestHeader(
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
              const ReassignmentHeroIllustration(),
              const SizedBox(height: Spacing.xl),
              ValueListenableBuilder<ReassignmentReason?>(
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
              const SizedBox(height: Spacing.md),
              ReassignmentNotesField(controller: _notesController),
              const SizedBox(height: Spacing.xl),
              ValueListenableBuilder<ReassignmentReason?>(
                valueListenable: _reasonNotifier,
                builder: (context, reason, _) {
                  return ReassignmentSubmitButton(
                    onPressed: reason != null ? _handleSubmit : null,
                  );
                },
              ),
              const SizedBox(height: Spacing.xs),
              TextButton(
                onPressed:
                    widget.onBackPressed ?? () => context.maybePopRoute(),
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
        ),
      ),
    );
  }
}


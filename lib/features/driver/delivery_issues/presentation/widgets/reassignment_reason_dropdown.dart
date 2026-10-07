import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/reassignment_reason.dart';

class ReassignmentReasonDropdown extends StatelessWidget {
  const ReassignmentReasonDropdown({
    super.key,
    required this.selectedReason,
    required this.onChanged,
  });

  final ReassignmentReason? selectedReason;
  final ValueChanged<ReassignmentReason?> onChanged;

  String _getReasonTitle(BuildContext context, ReassignmentReason reason) {
    final locale = context.localization;
    return switch (reason) {
      ReassignmentReason.vehicleFailure =>
        locale.reassignRequestReasonVehicleFailure,
      ReassignmentReason.accident => locale.reassignRequestReasonAccident,
      ReassignmentReason.emergency => locale.reassignRequestReasonEmergency,
      ReassignmentReason.healthIssue => locale.reassignRequestReasonHealthIssue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          locale.reassignRequestReasonLabel,
          style: getBoldStyle(
            fontSize: FontSize.size14,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.7),
              width: 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReassignmentReason>(
              value: selectedReason,
              isExpanded: true,
              dropdownColor: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusLg),
              hint: Text(
                locale.reassignRequestReasonHint,
                style: getRegularStyle(
                  fontSize: FontSize.size14,
                  color: color.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: color.onSurfaceVariant.withValues(alpha: 0.7),
                size: 24,
              ),
              items: ReassignmentReason.values.map((reason) {
                return DropdownMenuItem<ReassignmentReason>(
                  value: reason,
                  child: Text(
                    _getReasonTitle(context, reason),
                    style: getMediumStyle(
                      fontSize: FontSize.size14,
                      color: color.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.6),
              width: Spacing.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReassignmentReason>(
              value: selectedReason,
              isExpanded: true,
              hint: Text(
                locale.reassignRequestReasonHint,
                style: getRegularStyle(
                  fontSize: FontSize.size13,
                  color: color.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: color.onSurfaceVariant,
              ),
              items: ReassignmentReason.values.map((reason) {
                return DropdownMenuItem<ReassignmentReason>(
                  value: reason,
                  child: Text(
                    _getReasonTitle(context, reason),
                    style: getRegularStyle(
                      fontSize: FontSize.size13,
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

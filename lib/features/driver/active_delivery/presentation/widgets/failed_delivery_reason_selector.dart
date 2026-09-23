import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/delivery_failure_reason_entity.dart';

class FailedDeliveryReasonSelector extends StatelessWidget {
  const FailedDeliveryReasonSelector({
    super.key,
    required this.reasons,
    required this.selectedReasonId,
    required this.onReasonSelected,
    this.noteController,
  });

  final List<DeliveryFailureReasonEntity> reasons;
  final String selectedReasonId;
  final ValueChanged<String> onReasonSelected;
  final TextEditingController? noteController;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.driverFailureReasonLabel,
          style: getBoldStyle(
            fontSize: FontSize.size14,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        for (final reason in reasons) ...[
          _buildReasonTile(
            color: color,
            reason: reason,
            isSelected: reason.id == selectedReasonId,
            onTap: () => onReasonSelected(reason.id),
          ),
          const SizedBox(height: Spacing.xs),
        ],
        const SizedBox(height: Spacing.base),
        Text(
          locale.driverAdditionalNotesLabel,
          style: getMediumStyle(
            fontSize: FontSize.size13,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextField(
          controller: noteController,
          maxLines: 3,
          style: getRegularStyle(
            fontSize: FontSize.size13,
            color: color.onSurface,
          ),
          decoration: InputDecoration(
            hintText: locale.driverAdditionalNotesHint,
            hintStyle: getRegularStyle(
              fontSize: FontSize.size12,
              color: color.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            fillColor: color.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.inputRadius),
              borderSide: BorderSide(color: color.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.inputRadius),
              borderSide: BorderSide(color: color.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.inputRadius),
              borderSide: BorderSide(color: color.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonTile({
    required ColorScheme color,
    required DeliveryFailureReasonEntity reason,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.primaryContainer : color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: isSelected ? color.primary : color.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: Spacing.iconMd,
              color: isSelected ? color.primary : color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.title,
                    style: getSemiBoldStyle(
                      fontSize: FontSize.size13,
                      color: isSelected ? color.primary : color.onSurface,
                    ),
                  ),
                  if (reason.description != null &&
                      reason.description!.isNotEmpty) ...[
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      reason.description!,
                      style: getRegularStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

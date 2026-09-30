import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/delivery_issue_reason.dart';
import 'delivery_issue_reason_tile.dart';

class DeliveryIssueReasonSelector extends StatelessWidget {
  const DeliveryIssueReasonSelector({
    super.key,
    required this.selectedReason,
    required this.onReasonSelected,
  });

  final DeliveryIssueReason selectedReason;
  final ValueChanged<DeliveryIssueReason> onReasonSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          locale.reportIssueSelectReasonTitle,
          style: getBoldStyle(
            fontSize: FontSize.size14,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.reportIssueSelectReasonSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ...DeliveryIssueReason.values.map((reason) {
          final isSelected = reason == selectedReason;
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: DeliveryIssueReasonTile(
              reason: reason,
              isSelected: isSelected,
              onTap: () => onReasonSelected(reason),
            ),
          );
        }),
      ],
    );
  }
}

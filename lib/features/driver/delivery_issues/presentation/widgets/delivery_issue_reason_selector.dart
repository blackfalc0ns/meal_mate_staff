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
            fontSize: FontSize.size18,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.reportIssueSelectReasonSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size13,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.md),
        // Row 1: Customer No Answer & Address Unclear
        Row(
          children: [
            Expanded(
              child: DeliveryIssueReasonTile(
                reason: DeliveryIssueReason.customerNoAnswer,
                isSelected:
                    selectedReason == DeliveryIssueReason.customerNoAnswer,
                onTap: () =>
                    onReasonSelected(DeliveryIssueReason.customerNoAnswer),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: DeliveryIssueReasonTile(
                reason: DeliveryIssueReason.addressUnclear,
                isSelected:
                    selectedReason == DeliveryIssueReason.addressUnclear,
                onTap: () =>
                    onReasonSelected(DeliveryIssueReason.addressUnclear),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        // Row 2: Severe Delay & Box Damaged
        Row(
          children: [
            Expanded(
              child: DeliveryIssueReasonTile(
                reason: DeliveryIssueReason.severeDelay,
                isSelected: selectedReason == DeliveryIssueReason.severeDelay,
                onTap: () =>
                    onReasonSelected(DeliveryIssueReason.severeDelay),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: DeliveryIssueReasonTile(
                reason: DeliveryIssueReason.boxDamaged,
                isSelected: selectedReason == DeliveryIssueReason.boxDamaged,
                onTap: () =>
                    onReasonSelected(DeliveryIssueReason.boxDamaged),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        // Row 3: Refused Delivery (Full width)
        DeliveryIssueReasonTile(
          reason: DeliveryIssueReason.refusedDelivery,
          isSelected: selectedReason == DeliveryIssueReason.refusedDelivery,
          onTap: () =>
              onReasonSelected(DeliveryIssueReason.refusedDelivery),
        ),
      ],
    );
  }
}

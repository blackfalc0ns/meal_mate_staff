import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportTicketIssueCard extends StatelessWidget {
  const DriverSupportTicketIssueCard({
    super.key,
    required this.issueDescription,
  });

  final String issueDescription;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: Spacing.iconMd + 2,
                height: Spacing.iconMd + 2,
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                locale.driverSupportTicketIssueDetailsTitle,
                style: getBoldStyle(
                  fontSize: FontSize.size14,
                  color: color.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Text(
              issueDescription,
              style: getRegularStyle(
                fontSize: FontSize.size12,
                color: color.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

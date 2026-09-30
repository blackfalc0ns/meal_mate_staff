import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/delivery_issue_reason.dart';

class DeliveryIssueReasonTile extends StatelessWidget {
  const DeliveryIssueReasonTile({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  final DeliveryIssueReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  String _getReasonTitle(BuildContext context) {
    final locale = context.localization;
    return switch (reason) {
      DeliveryIssueReason.customerNoAnswer =>
        locale.reportIssueReasonCustomerNoAnswer,
      DeliveryIssueReason.addressUnclear =>
        locale.reportIssueReasonAddressUnclear,
      DeliveryIssueReason.severeDelay => locale.reportIssueReasonSevereDelay,
      DeliveryIssueReason.boxDamaged => locale.reportIssueReasonBoxDamaged,
      DeliveryIssueReason.refusedDelivery =>
        locale.reportIssueReasonRefusedDelivery,
    };
  }

  IconData _getReasonIcon() {
    return switch (reason) {
      DeliveryIssueReason.customerNoAnswer => Icons.phone_disabled_rounded,
      DeliveryIssueReason.addressUnclear => Icons.location_off_rounded,
      DeliveryIssueReason.severeDelay => Icons.access_time_rounded,
      DeliveryIssueReason.boxDamaged => Icons.inventory_2_outlined,
      DeliveryIssueReason.refusedDelivery => Icons.cancel_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.primary.withValues(alpha: 0.06)
                : color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(
              color: isSelected
                  ? color.primary
                  : color.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : Spacing.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color.primary : color.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  _getReasonTitle(context),
                  style: getMediumStyle(
                    fontSize: FontSize.size13,
                    color: isSelected ? color.primary : color.onSurface,
                  ),
                ),
              ),
              Icon(
                _getReasonIcon(),
                size: Spacing.iconSm,
                color: isSelected ? color.primary : color.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

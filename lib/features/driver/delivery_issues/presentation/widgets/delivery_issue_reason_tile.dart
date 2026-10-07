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

  Widget _buildReasonIcon(ColorScheme color) {
    if (reason == DeliveryIssueReason.refusedDelivery) {
      return Container(
        width: 22,
        height: 22,
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.5)),
            side: BorderSide(
              color: Color(0xFFE53935),
              width: 1.8,
            ),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.front_hand_rounded,
            size: 13,
            color: Color(0xFFE53935),
          ),
        ),
      );
    }

    final iconData = switch (reason) {
      DeliveryIssueReason.customerNoAnswer => Icons.phone_disabled_rounded,
      DeliveryIssueReason.addressUnclear => Icons.location_on_rounded,
      DeliveryIssueReason.severeDelay => Icons.access_time_filled_rounded,
      DeliveryIssueReason.boxDamaged => Icons.inventory_2_rounded,
      DeliveryIssueReason.refusedDelivery => Icons.front_hand_rounded,
    };

    return Icon(
      iconData,
      size: 20,
      color: color.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            border: Border.all(
              color: isSelected
                  ? color.primary
                  : color.outlineVariant.withValues(alpha: 0.6),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Icon on Start (Right in RTL)
              _buildReasonIcon(color),
              const SizedBox(width: Spacing.xs),
              // Reason Title in Center
              Expanded(
                child: Text(
                  _getReasonTitle(context),
                  style: isSelected
                      ? getBoldStyle(
                          fontSize: FontSize.size13,
                          color: color.primary,
                        )
                      : getMediumStyle(
                          fontSize: FontSize.size13,
                          color: color.onSurface,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              // Radio Button on End (Left in RTL)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? color.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? color.primary
                        : color.outlineVariant.withValues(alpha: 0.8),
                    width: isSelected ? 1.0 : 1.5,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 6,
                            height: 6,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

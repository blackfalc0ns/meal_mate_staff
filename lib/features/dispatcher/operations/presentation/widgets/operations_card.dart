import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/operation_item_entity.dart';
import 'operations_cancelled_info.dart';
import 'operations_customer_info.dart';
import 'operations_driver_info.dart';
import 'operations_reassigned_info.dart';
import 'operations_status_badge.dart';

class OperationsCard extends StatelessWidget {
  const OperationsCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final OperationItemEntity item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    Widget buildLeadingInfo() {
      if (item.status.isReassigned &&
          item.reassignedToDriverName != null &&
          item.driverName != null) {
        return OperationsReassignedInfo(
          fromDriverName: item.driverName!,
          toDriverName: item.reassignedToDriverName!,
          fromAvatarUrl: item.driverAvatarUrl,
          toAvatarUrl: item.reassignedToDriverAvatarUrl,
        );
      }
      if (item.status.isCancelled) {
        return OperationsCancelledInfo(
          reason: item.cancellationReason ?? '',
          orderId: item.orderId,
        );
      }
      return OperationsDriverInfo(
        name: item.driverName ?? '',
        orderId: item.orderId,
        avatarUrl: item.driverAvatarUrl,
        isOnline: item.isDriverOnline,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: Row(
              children: [
                // 1. Driver / Assignment / Cancel info
                buildLeadingInfo(),
                const SizedBox(width: Spacing.xs),

                // Divider
                Container(
                  width: 1,
                  height: 38,
                  color: color.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: Spacing.xs),

                // 2. Customer & Area info
                Expanded(
                  child: OperationsCustomerInfo(
                    customerName: item.customerName,
                    area: item.area,
                  ),
                ),
                const SizedBox(width: Spacing.xs),

                // Divider
                Container(
                  width: 1,
                  height: 38,
                  color: color.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: Spacing.xs),

                // 3. Status badge & Timestamp
                OperationsStatusBadge(
                  status: item.status,
                  timestamp: item.timestamp,
                ),
                const SizedBox(width: Spacing.xs / 2),

                // 4. Details Chevron
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 12,
                  color: color.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

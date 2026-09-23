import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/operation_item_entity.dart';
import '../../domain/entities/operation_status.dart';
import '../../domain/entities/operations_indicator_color.dart';
import 'operations_cancelled_info.dart';
import 'operations_customer_info.dart';
import 'operations_driver_info.dart';
import 'operations_reassigned_info.dart';
import 'operations_status_badge.dart';

class OperationsCard extends StatelessWidget {
  const OperationsCard({super.key, required this.item, dynamic onTap})
    : _onTapCallback = onTap;

  final OperationItemEntity item;
  final dynamic _onTapCallback;

  void _handleTap() {
    final callback = _onTapCallback;
    if (callback is ValueChanged<OperationItemEntity>) {
      callback(item);
    } else if (callback is VoidCallback) {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    Widget buildLeadingInfo() {
      if (item.status == OperationStatus.reassigned &&
          (item.replacementDriver != null || item.originalDriver != null)) {
        return OperationsReassignedInfo(
          fromDriverName: item.originalDriver?.name ?? item.driverName ?? '',
          toDriverName:
              item.replacementDriver?.name ?? item.reassignedToDriverName ?? '',
          fromAvatarUrl: item.originalDriver?.avatarUrl ?? item.driverAvatarUrl,
          toAvatarUrl:
              item.replacementDriver?.avatarUrl ??
              item.reassignedToDriverAvatarUrl,
        );
      }

      if (item.status == OperationStatus.cancelled) {
        return OperationsCancelledInfo(
          reason: item.cancelledByText ?? item.cancellationReason ?? '',
          boxCode: item.boxCode,
        );
      }

      return OperationsDriverInfo(
        name: item.driver?.name ?? item.driverName ?? '',
        boxCode: item.boxCode,
        avatarUrl: item.driver?.avatarUrl ?? item.driverAvatarUrl,
        indicatorColor:
            item.driver?.indicatorColor ??
            (item.isDriverOnline
                ? OperationsIndicatorColor.green
                : OperationsIndicatorColor.unknown),
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
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        child: InkWell(
          onTap: _onTapCallback != null ? _handleTap : null,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                // 1. Driver info or status-specific leading info
                Expanded(flex: 5, child: buildLeadingInfo()),
                const SizedBox(width: Spacing.xs),

                // 2. Customer info
                Expanded(
                  flex: 4,
                  child: OperationsCustomerInfo(
                    customerName: item.customer.name.isNotEmpty
                        ? item.customer.name
                        : item.customerName,
                    area: item.customer.area.isNotEmpty
                        ? item.customer.area
                        : item.area,
                  ),
                ),
                const SizedBox(width: Spacing.xs),

                // 3. Status badge + timestamp
                OperationsStatusBadge(
                  status: item.status,
                  timestamp: item.timeText.isNotEmpty
                      ? item.timeText
                      : item.timestamp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

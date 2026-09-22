import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_operations_status_entity.dart';
import '../../domain/entities/dispatcher_home_top_driver_entity.dart';
import 'dispatcher_home_drivers_card.dart';
import 'dispatcher_home_operations_card.dart';

class DispatcherHomeOperationsDriversSection extends StatelessWidget {
  const DispatcherHomeOperationsDriversSection({
    super.key,
    required this.operationsStatus,
    required this.topDrivers,
  });

  final DispatcherHomeOperationsStatusEntity operationsStatus;
  final List<DispatcherHomeTopDriverEntity> topDrivers;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    final operations = DispatcherHomeOperationsStatusEntity(
      completionRate: operationsStatus.completionRate,
      deliveredCount: operationsStatus.deliveredCount,
      deliveredLabel: locale.homeOpDelivered,
      inDeliveryCount: operationsStatus.inDeliveryCount,
      inDeliveryLabel: locale.homeOpInDelivery,
      pendingCount: operationsStatus.pendingCount,
      pendingLabel: locale.homeOpPending,
      cancelledCount: operationsStatus.cancelledCount,
      cancelledLabel: locale.homeOpCancelled,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 9,
            child: DispatcherHomeOperationsCard(
              operations: operations,
              onViewReports: () =>
                  context.pushNamed(AppRoutes.dispatcherOperations),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            flex: 11,
            child: DispatcherHomeDriversCard(
              drivers: topDrivers,
              onViewAllDrivers: () =>
                  context.pushNamed(AppRoutes.dispatcherDrivers),
              onDriverTap: (_) =>
                  context.pushNamed(AppRoutes.dispatcherDrivers),
            ),
          ),
        ],
      ),
    );
  }
}

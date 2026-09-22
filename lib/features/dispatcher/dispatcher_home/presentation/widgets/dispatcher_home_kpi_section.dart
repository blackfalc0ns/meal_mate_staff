import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_kpi_entity.dart';
import '../../domain/entities/dispatcher_home_overview_entity.dart';
import 'dispatcher_home_kpi_row.dart';

class DispatcherHomeKpiSection extends StatelessWidget {
  const DispatcherHomeKpiSection({
    super.key,
    required this.kpis,
  });

  final DispatcherHomeKpisEntity kpis;

  void _handleKpiTap(BuildContext context, DispatcherHomeKpiItemEntity item) {
    switch (item.id) {
      case 'total':
      case 'delivery':
      case 'pending':
        context.pushNamed(AppRoutes.dispatcherOrders);
      case 'issues':
        context.pushNamed(AppRoutes.dispatcherSupport);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    final items = [
      DispatcherHomeKpiItemEntity(
        id: 'total',
        label: locale.homeKpiTotalOrders,
        value: '${kpis.totalOrdersToday}',
        iconAsset: AppAssets.dispatcherHomeKpiBox,
        accentColorType: DispatcherHomeKpiColorType.purple,
      ),
      DispatcherHomeKpiItemEntity(
        id: 'delivery',
        label: locale.homeKpiInDelivery,
        value: '${kpis.inDeliveryCount}',
        iconAsset: AppAssets.dispatcherHomeKpiTruck,
        accentColorType: DispatcherHomeKpiColorType.blue,
      ),
      DispatcherHomeKpiItemEntity(
        id: 'pending',
        label: locale.homeKpiPendingAssignment,
        value: '${kpis.pendingAssignmentCount}',
        iconAsset: AppAssets.dispatcherHomeKpiClock,
        accentColorType: DispatcherHomeKpiColorType.orange,
      ),
      DispatcherHomeKpiItemEntity(
        id: 'issues',
        label: locale.homeKpiActiveIssues,
        value: '${kpis.activeIssuesCount}',
        iconAsset: AppAssets.dispatcherHomeKpiInfo,
        accentColorType: DispatcherHomeKpiColorType.red,
      ),
    ];

    return DispatcherHomeKpiRow(
      items: items,
      onItemTap: (item) => _handleKpiTap(context, item),
    );
  }
}

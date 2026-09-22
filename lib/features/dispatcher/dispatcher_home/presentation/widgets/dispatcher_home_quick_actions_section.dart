import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_quick_action_entity.dart';
import 'dispatcher_home_quick_actions.dart';

class DispatcherHomeQuickActionsSection extends StatelessWidget {
  const DispatcherHomeQuickActionsSection({super.key});

  void _handleQuickAction(
    BuildContext context,
    DispatcherHomeQuickActionType type,
  ) {
    switch (type) {
      case DispatcherHomeQuickActionType.assignDriver:
        context.pushNamed(AppRoutes.dispatcherOrders);
      case DispatcherHomeQuickActionType.solveIssues:
        context.pushNamed(AppRoutes.dispatcherSupport);
      case DispatcherHomeQuickActionType.driversMap:
        context.pushNamed(AppRoutes.dispatcherMap);
      case DispatcherHomeQuickActionType.allDrivers:
        context.pushNamed(AppRoutes.dispatcherDrivers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    final quickActions = <DispatcherHomeQuickActionEntity>[
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.assignDriver,
        title: locale.homeActionAssignDriver,
        iconAsset: AppAssets.dispatcherHomeActionAssignDriver,
      ),
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.solveIssues,
        title: locale.homeActionSolveIssues,
        iconAsset: AppAssets.dispatcherHomeActionSolveIssues,
      ),
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.driversMap,
        title: locale.homeActionDriversMap,
        iconAsset: AppAssets.dispatcherHomeActionDriversMap,
      ),
      DispatcherHomeQuickActionEntity(
        type: DispatcherHomeQuickActionType.allDrivers,
        title: locale.homeActionAllDrivers,
        iconAsset: AppAssets.dispatcherHomeActionAllDrivers,
      ),
    ];

    return DispatcherHomeQuickActions(
      actions: quickActions,
      onActionTap: (type) => _handleQuickAction(context, type),
    );
  }
}

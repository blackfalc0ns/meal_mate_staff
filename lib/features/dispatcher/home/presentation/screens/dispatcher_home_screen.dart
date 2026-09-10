import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_area_summary_entity.dart';
import '../../domain/entities/dispatcher_home_kpi_entity.dart';
import '../../domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import '../../domain/entities/dispatcher_home_operations_status_entity.dart';
import '../../domain/entities/dispatcher_home_quick_action_entity.dart';
import '../../domain/entities/dispatcher_home_top_driver_entity.dart';
import '../../domain/fake_data/dispatcher_home_fake_data.dart';
import '../widgets/dispatcher_home_alert_banner.dart';
import '../widgets/dispatcher_home_areas_card.dart';
import '../widgets/dispatcher_home_drivers_card.dart';
import '../widgets/dispatcher_home_header.dart';
import '../widgets/dispatcher_home_kpi_row.dart';
import '../widgets/dispatcher_home_map_card.dart';
import '../widgets/dispatcher_home_operations_card.dart';
import '../widgets/dispatcher_home_quick_actions.dart';

class DispatcherHomeScreen extends StatelessWidget {
  const DispatcherHomeScreen({
    super.key,
    this.kpiItems = DispatcherHomeFakeData.kpiItems,
    this.quickActions = DispatcherHomeFakeData.quickActions,
    this.mapDriverPins = DispatcherHomeFakeData.mapDriverPins,
    this.operationsStatus = DispatcherHomeFakeData.operationsStatus,
    this.topDrivers = DispatcherHomeFakeData.topDrivers,
    this.areaSummaries = DispatcherHomeFakeData.areaSummaries,
    this.alert = DispatcherHomeFakeData.alert,
  });

  final List<DispatcherHomeKpiItemEntity> kpiItems;
  final List<DispatcherHomeQuickActionEntity> quickActions;
  final List<DispatcherHomeMapDriverPinEntity> mapDriverPins;
  final DispatcherHomeOperationsStatusEntity operationsStatus;
  final List<DispatcherHomeTopDriverEntity> topDrivers;
  final List<DispatcherHomeAreaSummaryEntity> areaSummaries;
  final dynamic alert;

  void _handleQuickAction(BuildContext context, DispatcherHomeQuickActionType type) {
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
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DispatcherHomeHeader(),
              const SizedBox(height: Spacing.base),
              DispatcherHomeKpiRow(items: kpiItems),
              const SizedBox(height: Spacing.lg),
              DispatcherHomeQuickActions(
                actions: quickActions,
                onActionTap: (type) => _handleQuickAction(context, type),
              ),
              const SizedBox(height: Spacing.lg),
              DispatcherHomeMapCard(
                pins: mapDriverPins,
                onViewFullMap: () => context.pushNamed(AppRoutes.dispatcherMap),
                onFocusLocation: () {},
                onPinTap: (_) => context.pushNamed(AppRoutes.dispatcherMap),
              ),
              const SizedBox(height: Spacing.lg),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 9,
                      child: DispatcherHomeOperationsCard(
                        operations: operationsStatus,
                        onViewReports: () {},
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
              ),
              const SizedBox(height: Spacing.lg),
              DispatcherHomeAreasCard(
                areas: areaSummaries,
                onViewAll: () {},
                onAreaTap: (_) {},
              ),
              const SizedBox(height: Spacing.lg),
              DispatcherHomeAlertBanner(
                alert: alert,
                onTap: () => context.pushNamed(AppRoutes.dispatcherSupport),
              ),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/app_bottom_nav_bar.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

import '../manager/driver_active_home_state.dart';
import '../manager/driver_active_home_view_model.dart';
import '../widgets/active_home/driver_active_home_header.dart';
import '../widgets/active_home/driver_active_status_location_row.dart';
import '../widgets/active_home/driver_current_order_card.dart';
import '../widgets/active_home/driver_daily_goal_card.dart';
import '../widgets/active_home/driver_daily_performance_section.dart';
import '../widgets/active_home/driver_daily_summary_section.dart';
import '../widgets/active_home/driver_home_map_card.dart';
import '../widgets/active_home/driver_issues_help_banner.dart';

class DriverActiveHomeScreen extends StatefulWidget {
  const DriverActiveHomeScreen({
    super.key,
    this.viewModel,
    this.onNotificationTap,
    this.onMenuTap,
    this.onOrderDetailsTap,
    this.onIssuesTap,
  });

  final DriverActiveHomeViewModel? viewModel;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onOrderDetailsTap;
  final VoidCallback? onIssuesTap;

  @override
  State<DriverActiveHomeScreen> createState() => _DriverActiveHomeScreenState();
}

class _DriverActiveHomeScreenState extends State<DriverActiveHomeScreen> {
  late final DriverActiveHomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ??
        (getIt.isRegistered<DriverActiveHomeViewModel>()
            ? getIt<DriverActiveHomeViewModel>()
            : DriverActiveHomeViewModel(
                getDriverActiveHomeUseCase: getIt(),
              ));
    unawaited(_viewModel.loadOverview());
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return BlocBuilder<DriverActiveHomeViewModel, DriverActiveHomeState>(
      bloc: _viewModel,
      builder: (context, state) {
        final data = state.data;

        return Scaffold(
          backgroundColor: color.surface,
          extendBody: true,
          bottomNavigationBar: AppBottomNavBar(
            selectedIndex: 0,
            onItemSelected: (index) {
              if (index == 0) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              } else {
                unawaited(
                  context.pushNamedAndRemoveUntil(
                    AppRoutes.appShell,
                    (route) => false,
                    arguments: AppShellRouteArgs(
                      role: UserRole.driver,
                      initialIndex: index,
                    ),
                  ),
                );
              }
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.screenH,
                vertical: Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DriverActiveHomeHeader(
                    onNotificationTap: widget.onNotificationTap ??
                        () {
                          unawaited(
                            context.pushNamed(AppRoutes.driverNotifications),
                          );
                        },
                    onMenuTap: widget.onMenuTap ??
                        () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                  ),
                  const SizedBox(height: Spacing.md),
                  if (data != null) ...[
                    DriverActiveStatusLocationRow(
                      location: data.currentLocation,
                    ),
                    const SizedBox(height: Spacing.md),
                    DriverDailyGoalCard(goal: data.goal),
                    const SizedBox(height: Spacing.md),
                    const DriverHomeMapCard(),
                    const SizedBox(height: Spacing.md),
                    DriverCurrentOrderCard(
                      order: data.currentOrder,
                      onDetailsTap: widget.onOrderDetailsTap,
                    ),
                    const SizedBox(height: Spacing.md),
                    DriverIssuesHelpBanner(
                      onTap: widget.onIssuesTap,
                    ),
                    const SizedBox(height: Spacing.base),
                    DriverDailySummarySection(summary: data.summary),
                    const SizedBox(height: Spacing.base),
                    DriverDailyPerformanceSection(
                      performance: data.performance,
                    ),
                    const SizedBox(height: Spacing.base),
                  ] else ...[
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: Spacing.bottomNavHeight + Spacing.base,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

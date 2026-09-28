import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/app_bottom_nav_bar.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

import '../manager/driver_active_home_state.dart';
import '../manager/driver_active_home_view_model.dart';
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
          appBar: CustomAppBar(
            showBackButton: false,
            backgroundColor: color.surface,
            leading: IconButton(
              onPressed: widget.onMenuTap ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
              icon: Icon(
                Icons.menu_rounded,
                color: color.onSurface,
                size: 28,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            titleWidget: Image.asset(
              AppAssets.authHeaderLogo,
              height: 28,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: Spacing.screenH),
                child: InkWell(
                  onTap: widget.onNotificationTap ??
                      () {
                        unawaited(
                          context.pushNamed(AppRoutes.driverNotifications),
                        );
                      },
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.surface,
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      border: Border.all(
                        color: color.outlineVariant.withValues(alpha: 0.5),
                        width: Spacing.hairline,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_rounded,
                          color: Color(0xFF1E293B),
                          size: 22,
                        ),
                        Positioned(
                          top: 10,
                          right: 11,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                vertical: Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.screenH,
                      ),
                      child: DriverActiveStatusLocationRow(
                        location: data.currentLocation,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Stack(
                      children: [
                        const Positioned(
                          top: 40,
                          bottom: 60,
                          left: 0,
                          right: 0,
                          child: DriverHomeMapCard(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.screenH,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DriverDailyGoalCard(goal: data.goal),
                              const SizedBox(height: 175),
                              DriverCurrentOrderCard(
                                order: data.currentOrder,
                                onDetailsTap: widget.onOrderDetailsTap,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.screenH,
                      ),
                      child: DriverIssuesHelpBanner(
                        onTap: widget.onIssuesTap,
                      ),
                    ),
                    const SizedBox(height: Spacing.base),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.screenH,
                      ),
                      child: DriverDailySummarySection(summary: data.summary),
                    ),
                    const SizedBox(height: Spacing.base),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.screenH,
                      ),
                      child: DriverDailyPerformanceSection(
                        performance: data.performance,
                      ),
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

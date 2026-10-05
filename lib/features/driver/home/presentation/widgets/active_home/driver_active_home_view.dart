import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/features/driver/tracking/data/services/driver_location_service.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_current_order_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_performance_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_summary_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';
import 'driver_active_status_location_row.dart';
import 'driver_current_order_card.dart';
import 'driver_daily_goal_card.dart';
import 'driver_daily_performance_section.dart';
import 'driver_daily_summary_section.dart';
import 'driver_home_map_card.dart';
import 'driver_issues_help_banner.dart';

class DriverActiveHomeView extends StatefulWidget {
  const DriverActiveHomeView({
    super.key,
    required this.home,
    this.onRefresh,
    this.onOrderDetailsTap,
    this.onIssuesTap,
  });

  final DriverHomeEntity home;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onOrderDetailsTap;
  final VoidCallback? onIssuesTap;

  @override
  State<DriverActiveHomeView> createState() => _DriverActiveHomeViewState();
}

class _DriverActiveHomeViewState extends State<DriverActiveHomeView> {
  @override
  void initState() {
    super.initState();
    _checkLocationTrackingIfNeeded();
  }

  @override
  void didUpdateWidget(covariant DriverActiveHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.home.currentDeliveryTask != null &&
        oldWidget.home.currentDeliveryTask == null) {
      _checkLocationTrackingIfNeeded();
    }
  }

  void _checkLocationTrackingIfNeeded() {
    // Location permission and live-location tracking start ONLY when active delivery task requires tracking
    if (widget.home.currentDeliveryTask != null) {
      if (getIt.isRegistered<DriverLocationService>()) {
        unawaited(getIt<DriverLocationService>().checkAndRequestPermission());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = widget.home;
    final task = home.currentDeliveryTask;
    final target = home.targetProgress;
    final summary = home.todaySummary;
    final performance = home.dailyPerformance;

    final Widget content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & Location Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
            child: DriverActiveStatusLocationRow(
              location: home.nextLocationText ?? '',
              statusText: home.currentStatusText.isNotEmpty
                  ? home.currentStatusText
                  : null,
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Map & Main Cards Stack
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
                    if (target != null)
                      DriverDailyGoalCard(targetProgress: target),
                    // If target progress is null but current order exists, give spacing
                    if (target != null && task != null)
                      const SizedBox(height: 175)
                    else if (target != null)
                      const SizedBox(height: Spacing.base)
                    else
                      const SizedBox(height: Spacing.sm),

                    // Current order card is shown ONLY when delivery task exists
                    if (task != null)
                      DriverCurrentOrderCard(
                        order: DriverCurrentOrderEntity(
                          orderId: task.boxId,
                          orderCode: task.boxCode.isNotEmpty
                              ? task.boxCode
                              : task.boxId,
                          clientName: task.customerName,
                          address: task.deliveryAddress,
                          mealsCount: task.mealsCount,
                          deliveryTime: task.deliveryTimeSlot,
                          imageAsset: AppAssets.driverOrderBox3d,
                        ),
                        onDetailsTap: widget.onOrderDetailsTap,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Issues help banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
            child: DriverIssuesHelpBanner(onTap: widget.onIssuesTap),
          ),
          const SizedBox(height: Spacing.base),

          // Today Summary Section (Only when present)
          if (summary != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
              child: DriverDailySummarySection(
                summary: DriverDailySummaryEntity(
                  incompleteCount: summary.failedDeliveriesCount,
                  inDeliveryCount:
                      (summary.completedTripsCount -
                              summary.totalDeliveredBoxesCount)
                          .clamp(0, 999),
                  deliveredCount: summary.totalDeliveredBoxesCount,
                  totalOrdersCount: summary.completedBoxesCount,
                ),
              ),
            ),
            const SizedBox(height: Spacing.base),
          ],

          // Daily Performance Section (Only when present)
          if (performance != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
              child: DriverDailyPerformanceSection(
                performance: DriverDailyPerformanceEntity(
                  averageDeliveryTime:
                      '${performance.onTimeDeliveryRate.toStringAsFixed(0)}%',
                  distanceCovered: '${performance.deliveredOrdersCount}',
                  onTimeRate: performance.customerRating.toStringAsFixed(1),
                ),
              ),
            ),
            const SizedBox(height: Spacing.base),
          ],

          const SizedBox(height: Spacing.bottomNavHeight + Spacing.base),
        ],
      ),
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(onRefresh: widget.onRefresh!, child: content);
    }

    return content;
  }
}

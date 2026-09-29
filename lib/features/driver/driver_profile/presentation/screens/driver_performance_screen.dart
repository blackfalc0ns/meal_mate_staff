import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_entity.dart';
import '../../domain/fake_data/driver_performance_fake_data.dart';
import '../widgets/driver_performance_deliveries_card.dart';
import '../widgets/driver_performance_distance_card.dart';
import '../widgets/driver_performance_excellence_banner.dart';
import '../widgets/driver_performance_header.dart';
import '../widgets/driver_performance_on_time_card.dart';
import '../widgets/driver_performance_period_toggle.dart';
import '../widgets/driver_performance_section_title.dart';
import '../widgets/driver_performance_summary_card.dart';
import '../widgets/driver_performance_working_hours_card.dart';

class DriverPerformanceScreen extends StatefulWidget {
  const DriverPerformanceScreen({
    super.key,
    this.performance,
    this.showBackButton = true,
    this.onBackTap,
    this.onViewDetailsTap,
  });

  final DriverPerformanceEntity? performance;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onViewDetailsTap;

  @override
  State<DriverPerformanceScreen> createState() =>
      _DriverPerformanceScreenState();
}

class _DriverPerformanceScreenState extends State<DriverPerformanceScreen> {
  late final ValueNotifier<bool> _isTodayNotifier;

  @override
  void initState() {
    super.initState();
    _isTodayNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _isTodayNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isTodayNotifier,
          builder: (context, isToday, _) {
            final activePerformance = widget.performance ??
                (isToday
                    ? DriverPerformanceFakeData.todayPerformance
                    : DriverPerformanceFakeData.thisWeekPerformance);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.screenH,
                vertical: Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DriverPerformanceHeader(
                    formattedDate: activePerformance.formattedDate,
                    isOnline: activePerformance.isOnline,
                    showBackButton: widget.showBackButton,
                    onBackTap: widget.onBackTap,
                  ),
                  const SizedBox(height: Spacing.md),
                  DriverPerformancePeriodToggle(
                    isTodaySelected: isToday,
                    onToggle: (val) => _isTodayNotifier.value = val,
                  ),
                  const SizedBox(height: Spacing.md),
                  DriverPerformanceSummaryCard(
                    performance: activePerformance,
                  ),
                  const SizedBox(height: Spacing.base),
                  const DriverPerformanceSectionTitle(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DriverPerformanceOnTimeCard(
                          cardData: activePerformance.onTimeCard,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: DriverPerformanceDeliveriesCard(
                          cardData: activePerformance.deliveriesCard,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DriverPerformanceDistanceCard(
                          cardData: activePerformance.distanceCard,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: DriverPerformanceWorkingHoursCard(
                          cardData: activePerformance.workingHoursCard,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  DriverPerformanceExcellenceBanner(
                    onViewDetailsTap: widget.onViewDetailsTap,
                  ),
                  const SizedBox(height: Spacing.md),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

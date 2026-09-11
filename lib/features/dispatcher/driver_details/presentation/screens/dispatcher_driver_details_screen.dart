import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_details_entity.dart';
import '../../domain/fake_data/driver_details_fake_data.dart';
import '../widgets/driver_details_action_buttons.dart';
import '../widgets/driver_details_app_bar.dart';
import '../widgets/driver_details_boxes_card.dart';
import '../widgets/driver_details_kpi_row.dart';
import '../widgets/driver_details_location_card.dart';
import '../widgets/driver_details_performance_card.dart';
import '../widgets/driver_details_profile_card.dart';

class DispatcherDriverDetailsScreen extends StatelessWidget {
  const DispatcherDriverDetailsScreen({
    super.key,
    this.driver = DriverDetailsFakeData.defaultDriver,
    this.onBack,
    this.onMore,
    this.onOpenMap,
    this.onSendMessage,
    this.onCall,
    this.onNavItemSelected,
  });

  final DriverDetailsEntity driver;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final VoidCallback? onOpenMap;
  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;
  final ValueChanged<int>? onNavItemSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverDetailsAppBar(onBack: onBack, onMore: onMore),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.xs),
              DriverDetailsProfileCard(driver: driver),
              const SizedBox(height: Spacing.xs),
              DriverDetailsKpiRow(driver: driver),
              const SizedBox(height: Spacing.sm),
              DriverDetailsLocationCard(
                driver: driver,
                onOpenMap:
                    onOpenMap ??
                    () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.dispatcherMap),
              ),
              const SizedBox(height: Spacing.xs),
              DriverDetailsBoxesCard(boxes: driver.activeBoxes),
              const SizedBox(height: Spacing.xs),
              DriverDetailsPerformanceCard(driver: driver),
              const SizedBox(height: Spacing.xs),
              DriverDetailsActionButtons(
                onSendMessage: onSendMessage,
                onCall: onCall,
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}

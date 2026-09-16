import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../dispatcher_box_tracking/domain/entities/box_tracking_driver_entity.dart';
import '../../../dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import '../../../dispatcher_box_tracking/domain/fake_data/box_tracking_fake_data.dart';
import '../../domain/entities/driver_active_box_entity.dart';
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
    this.onSelectBox,
    this.onNavItemSelected,
  });

  final DriverDetailsEntity driver;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final VoidCallback? onOpenMap;
  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;
  final ValueChanged<DriverActiveBoxEntity>? onSelectBox;
  final ValueChanged<int>? onNavItemSelected;

  void _handleBoxTap(BuildContext context, DriverActiveBoxEntity box) {
    if (onSelectBox != null) {
      onSelectBox!(box);
      return;
    }

    final trackingEntity = BoxTrackingEntity(
      boxId: box.boxId.replaceAll('#', ''),
      customerName: box.customerName,
      deliveryAddress: box.area,
      deliveryTime: box.time,
      status: box.isDelivering
          ? BoxTrackingStatus.onTheWay
          : BoxTrackingStatus.pickedUpByDriver,
      driver: BoxTrackingDriverEntity(
        id: driver.id,
        name: driver.name,
        phone: driver.phone,
        isOnline: driver.isAvailable,
      ),
      planType: 'دايت متوازن',
      orderDate: 'اليوم 09:50 ص',
      mealCount: '3 وجبات (يوم كامل)',
      customerNotes: 'يرجى الاتصال قبل الوصول',
      steps: BoxTrackingFakeData.defaultSteps,
    );

    Navigator.of(context).pushNamed(
      AppRoutes.boxTracking,
      arguments: trackingEntity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              DriverDetailsBoxesCard(
                boxes: driver.activeBoxes,
                onSelectBox: (box) => _handleBoxTap(context, box),
              ),
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

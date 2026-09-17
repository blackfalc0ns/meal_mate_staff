import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_received_box_item_entity.dart';
import '../../domain/fake_data/driver_boxes_received_fake_data.dart';
import '../widgets/driver_boxes_received_action_button.dart';
import '../widgets/driver_boxes_received_header.dart';
import '../widgets/driver_boxes_received_info_card.dart';
import '../widgets/driver_boxes_received_safety_banner.dart';
import '../widgets/driver_boxes_received_success_banner.dart';
import '../widgets/driver_received_box_card.dart';
import '../widgets/driver_received_boxes_header_bar.dart';

class DriverBoxesReceivedScreen extends StatelessWidget {
  const DriverBoxesReceivedScreen({
    super.key,
    this.boxes,
    this.onStartDelivery,
  });

  final List<DriverReceivedBoxItemEntity>? boxes;
  final VoidCallback? onStartDelivery;

  void _handleStartDelivery(BuildContext context) {
    if (onStartDelivery != null) {
      onStartDelivery!();
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.driverAssignedBoxes,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final receivedBoxes =
        boxes ?? DriverBoxesReceivedFakeData.defaultReceivedBoxes;

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
              const SizedBox(height: Spacing.sm),
              const DriverBoxesReceivedHeader(),
              const SizedBox(height: Spacing.base),
              const DriverBoxesReceivedSuccessBanner(),
              const SizedBox(height: Spacing.sm),
              const DriverBoxesReceivedInfoCard(),
              const SizedBox(height: Spacing.lg),
              DriverReceivedBoxesHeaderBar(count: receivedBoxes.length),
              const SizedBox(height: Spacing.sm),
              for (final item in receivedBoxes) ...[
                DriverReceivedBoxCard(item: item),
                const SizedBox(height: Spacing.sm),
              ],
              const SizedBox(height: Spacing.xs),
              const DriverBoxesReceivedSafetyBanner(),
              const SizedBox(height: Spacing.lg),
              DriverBoxesReceivedActionButton(
                onPressed: () => _handleStartDelivery(context),
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/routing/routing_extensions.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../domain/entities/assign_box_order_entity.dart';
import '../../domain/fake_data/assign_box_fake_data.dart';
import '../widgets/assign_box_bottom_actions.dart';
import '../widgets/assign_box_driver_card.dart';
import '../widgets/assign_box_drivers_header.dart';
import '../widgets/assign_box_recommended_card.dart';
import '../widgets/assign_box_summary_card.dart';

class AssignBoxScreen extends StatefulWidget {
  const AssignBoxScreen({super.key, this.order});

  final AssignBoxOrderEntity? order;

  @override
  State<AssignBoxScreen> createState() => _AssignBoxScreenState();
}

class _AssignBoxScreenState extends State<AssignBoxScreen> {
  late final AssignBoxOrderEntity _order;
  late String _selectedDriverId;

  @override
  void initState() {
    super.initState();
    _order = widget.order ?? AssignBoxFakeData.sampleOrder;
    _selectedDriverId = _order.recommendedDriver.id;
  }

  void _onDriverSelected(String driverId) {
    if (_selectedDriverId == driverId) return;
    setState(() {
      _selectedDriverId = driverId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: CustomAppBar(
        title: locale.assignBoxTitle(_order.boxCode),
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).maybePop(),
        actions: [NotificationButton(hasUnread: true, onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenH,
          vertical: Spacing.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AssignBoxSummaryCard(order: _order),
            const SizedBox(height: Spacing.base),
            AssignBoxRecommendedCard(
              driver: _order.recommendedDriver,
              isSelected: _selectedDriverId == _order.recommendedDriver.id,
              onSelected: () => _onDriverSelected(_order.recommendedDriver.id),
            ),
            const SizedBox(height: Spacing.lg),
            AssignBoxDriversHeader(onViewAllPressed: () {}),
            const SizedBox(height: Spacing.sm),
            ..._order.candidates.map(
              (candidate) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: AssignBoxDriverCard(
                  driver: candidate,
                  isSelected: _selectedDriverId == candidate.id,
                  onSelected: () => _onDriverSelected(candidate.id),
                ),
              ),
            ),
            const SizedBox(height: Spacing.base),
          ],
        ),
      ),
      bottomNavigationBar: AssignBoxBottomActions(
        onViewBoxPressed: () {},
        onConfirmPressed: () {
          context.pop();
        },
      ),
    );
  }
}

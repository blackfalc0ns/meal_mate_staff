import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_order_entity.dart';
import 'dispatcher_order_card.dart';

class DispatcherOrdersList extends StatelessWidget {
  const DispatcherOrdersList({
    super.key,
    required this.orders,
    this.onAssignOrder,
    this.onOrderDetails,
  });

  final List<DispatcherOrderEntity> orders;
  final ValueChanged<DispatcherOrderEntity>? onAssignOrder;
  final ValueChanged<DispatcherOrderEntity>? onOrderDetails;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return DispatcherOrderCard(
          order: order,
          onAssignPressed: () {
            if (onAssignOrder != null) {
              onAssignOrder!(order);
            } else {
              context.pushNamed(AppRoutes.assignBox);
            }
          },
          onDetailsPressed: () => onOrderDetails?.call(order),
        );
      },
    );
  }
}

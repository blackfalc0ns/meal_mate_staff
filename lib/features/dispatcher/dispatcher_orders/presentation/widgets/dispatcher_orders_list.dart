import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/assign_box_route_arguments.dart';
import '../../../../../config/routing/arguments/box_tracking_route_arguments.dart';
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final order = orders[index];
          return RepaintBoundary(
            child: DispatcherOrderCard(
              key: ValueKey(order.id),
              order: order,
              onAssignPressed: () {
                if (onAssignOrder != null) {
                  onAssignOrder!(order);
                } else {
                  context.pushNamed(
                    AppRoutes.assignBox,
                    arguments: AssignBoxRouteArgs(boxId: order.boxId),
                  );
                }
              },
              onDetailsPressed: () {
                if (onOrderDetails != null) {
                  onOrderDetails!(order);
                } else {
                  context.pushNamed(
                    AppRoutes.boxTracking,
                    arguments: BoxTrackingRouteArguments(boxId: order.boxId),
                  );
                }
              },
            ),
          );
        },
        childCount: orders.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}

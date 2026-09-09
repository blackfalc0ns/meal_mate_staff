import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_order_entity.dart';
import 'dispatcher_priority_badge.dart';

class DispatcherOrderCardHeader extends StatelessWidget {
  const DispatcherOrderCardHeader({super.key, required this.order});

  final DispatcherOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: Spacing.iconSm + Spacing.xs / 2,
              color: color.primary,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              order.boxCode,
              style: getBoldStyle(
                color: color.primary,
                fontSize: FontSize.size14,
              ),
            ),
          ],
        ),
        DispatcherPriorityBadge(priority: order.priority),
      ],
    );
  }
}

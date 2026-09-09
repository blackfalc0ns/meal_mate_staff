import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_order_entity.dart';
import 'dispatcher_driver_suggestion_tile.dart';
import 'dispatcher_order_action_buttons.dart';
import 'dispatcher_order_card_header.dart';
import 'dispatcher_order_info_section.dart';

class DispatcherOrderCard extends StatelessWidget {
  const DispatcherOrderCard({
    super.key,
    required this.order,
    this.onAssignPressed,
    this.onDetailsPressed,
  });

  final DispatcherOrderEntity order;
  final VoidCallback? onAssignPressed;
  final VoidCallback? onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.xs,
      ),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
        border: Border.all(color: color.outline, width: Spacing.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DispatcherOrderCardHeader(order: order),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DispatcherOrderInfoSection(order: order),
                    const SizedBox(height: Spacing.sm),
                    DispatcherDriverSuggestionTile(order: order),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              DispatcherOrderActionButtons(
                onAssignPressed: onAssignPressed,
                onDetailsPressed: onDetailsPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

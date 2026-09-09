import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_order_entity.dart';

class DispatcherDriverSuggestionTile extends StatelessWidget {
  const DispatcherDriverSuggestionTile({super.key, required this.order});

  final DispatcherOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final suggestionText = order.isLeastLoaded
        ? locale.dispatcherSuggestionLeastLoaded(order.suggestedDriverName)
        : locale.dispatcherSuggestionNearest(order.suggestedDriverName);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.dispatcherSuggestionSurface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: Spacing.sm,
            backgroundColor: color.primaryBorder,
            child: Icon(
              Icons.person,
              size: Spacing.iconSm - Spacing.xs,
              color: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              suggestionText,
              style: getMediumStyle(
                color: color.primary,
                fontSize: FontSize.size11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

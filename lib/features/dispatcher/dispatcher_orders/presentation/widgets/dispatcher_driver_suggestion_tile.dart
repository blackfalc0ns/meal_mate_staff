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

    final prefix = order.isLeastLoaded
        ? locale.dispatcherLeastBusyPrefix
        : locale.dispatcherSuggestionPrefix;

    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.xs,
        end: Spacing.md,
        top: Spacing.xs,
        bottom: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.dispatcherSuggestionSurface,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.iconMd,
            height: Spacing.iconMd,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.surface,
              border: Border.all(color: color.primary, width: Spacing.border),
            ),
            padding: const EdgeInsets.all(Spacing.border),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.outline.withValues(alpha: 0.25),
              ),
              child: Icon(
                Icons.person,
                size: Spacing.iconSm,
                color: color.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$prefix ',
                    style: getBoldStyle(
                      color: color.primary,
                      fontSize: FontSize.size11,
                    ),
                  ),
                  TextSpan(
                    text: order.suggestedDriverName,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                    ),
                  ),
                ],
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

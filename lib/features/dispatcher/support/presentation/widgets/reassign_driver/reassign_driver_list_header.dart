import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';

class ReassignDriverListHeader extends StatelessWidget {
  const ReassignDriverListHeader({super.key, this.onFilterTap});

  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locale.reassignDriverSelectTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs / 2),
              Text(
                locale.reassignDriverSelectSubtitle,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xs),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.xs / 2),
                Text(
                  locale.reassignDriverFilter,
                  style: getSemiBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

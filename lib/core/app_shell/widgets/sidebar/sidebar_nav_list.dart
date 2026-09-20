import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../domain/entities/sidebar_item_entity.dart';
import '../../../extensions/extensions.dart';
import 'sidebar_nav_item_tile.dart';

/// Navigation list section displaying sidebar items with dividers.
class SidebarNavList extends StatelessWidget {
  const SidebarNavList({super.key, required this.items, this.onItemTap});

  final List<SidebarItemEntity> items;
  final ValueChanged<SidebarItemEntity>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          SidebarNavItemTile(
            item: items[i],
            onTap: () => onItemTap?.call(items[i]),
          ),
          if (i < items.length - 1)
            Divider(
              height: 1,
              thickness: Spacing.hairline,
              color: color.outlineVariant.withValues(alpha: 0.3),
            ),
        ],
      ],
    );
  }
}

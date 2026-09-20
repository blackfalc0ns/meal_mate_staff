import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../domain/entities/sidebar_item_entity.dart';
import '../../../extensions/extensions.dart';
import 'sidebar_notification_badge.dart';

/// Single item tile in the sidebar navigation list.
class SidebarNavItemTile extends StatelessWidget {
  const SidebarNavItemTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final SidebarItemEntity item;
  final VoidCallback? onTap;

  static const double _tileHeight = 42.0;
  static const double _indicatorWidth = 5.0;
  static const double _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final isSelected = item.isSelected;
    final itemColor = isSelected ? color.primary : color.onSurface;
    final itemBgColor = isSelected
        ? color.primary.withValues(alpha: 0.08)
        : Colors.transparent;

    Widget? leadingIcon;
    if (item.iconAsset != null) {
      leadingIcon = SvgPicture.asset(
        item.iconAsset!,
        width: _iconSize,
        height: _iconSize,
        colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
      );
    } else if (item.iconData != null) {
      leadingIcon = Icon(
        item.iconData,
        size: _iconSize,
        color: itemColor,
      );
    }

    return Material(
      color: itemBgColor,
      child: InkWell(
        onTap: () {
          item.onTap?.call();
          onTap?.call();
        },
        child: Container(
          height: _tileHeight,
          decoration: BoxDecoration(
            border: isSelected
                ? BorderDirectional(
                    start: BorderSide(
                      color: color.primary,
                      width: _indicatorWidth,
                    ),
                  )
                : null,
          ),
          padding: const EdgeInsetsDirectional.only(
            start: Spacing.base,
            end: Spacing.base,
          ),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                leadingIcon,
                const SizedBox(width: Spacing.md),
              ],
              Expanded(
                child: Text(
                  item.title,
                  style: isSelected
                      ? getBoldStyle(fontSize: 12, color: itemColor)
                      : getRegularStyle(fontSize: 12, color: itemColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.badgeCount != null && item.badgeCount! > 0) ...[
                SidebarNotificationBadge(count: item.badgeCount!),
                const SizedBox(width: Spacing.xs),
              ],
              if (!isSelected)
                Icon(
                  isRtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: Spacing.base,
                  color: color.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

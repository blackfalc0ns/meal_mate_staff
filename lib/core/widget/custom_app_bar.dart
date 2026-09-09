import 'package:flutter/material.dart';

import '../../config/theme/font_manager.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/styles_manager.dart';
import '../extensions/extensions.dart';
import 'custom_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.showBackButton = true,
    this.leading,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation,
    this.primary = true,
  });

  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final bool showBackButton;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Color? backgroundColor;
  final double? elevation;
  final bool primary;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    Widget? computedTitle;
    if (titleWidget != null) {
      computedTitle = titleWidget;
    } else if (title != null) {
      if (subtitle != null) {
        computedTitle = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getBoldStyle(
                fontSize: FontSize.size16,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.border),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getRegularStyle(
                fontSize: FontSize.size10,
                color: color.onSurfaceVariant,
              ),
            ),
          ],
        );
      } else {
        computedTitle = Text(title!);
      }
    }

    return AppBar(
      primary: primary,
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      leading: leading ??
          (showBackButton
              ? CustomBackButton(onPressed: onBackPressed)
              : null),
      title: computedTitle,
      actions: actions,
    );
  }
}


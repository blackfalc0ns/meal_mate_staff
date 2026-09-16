import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherNotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DispatcherNotificationsAppBar({
    super.key,
    this.onFilterPressed,
    this.onNotificationPressed,
    this.onBackPressed,
  });

  final VoidCallback? onFilterPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(Spacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final canPop = Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: Container(
        height: Spacing.appBarHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (canPop)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                iconSize: Spacing.iconSm + Spacing.xs,
                color: color.onSurface,
                onPressed: onBackPressed ?? () => context.maybePopRoute(),
              )
            else
              InkWell(
                onTap: onNotificationPressed,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: Container(
                  width: Spacing.buttonSmallHeight - Spacing.xs,
                  height: Spacing.buttonSmallHeight - Spacing.xs,
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    border: Border.all(
                      color: color.notificationHeaderBorder,
                      width: Spacing.border,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications,
                        size: Spacing.iconMd - Spacing.xs,
                        color: color.onSurface,
                      ),
                      PositionedDirectional(
                        top: Spacing.xs + Spacing.border,
                        end: Spacing.xs + Spacing.border,
                        child: Container(
                          width: Spacing.sm - Spacing.border,
                          height: Spacing.sm - Spacing.border,
                          decoration: BoxDecoration(
                            color: color.notificationUnreadDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Text(
              locale.notificationsTitle,
              style: getBoldStyle(
                fontSize: FontSize.size16,
                color: color.onSurface,
              ),
            ),
            InkWell(
              onTap: onFilterPressed,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xs),
                child: Image.asset(
                  AppAssets.notificationFilterSlider,
                  width: Spacing.iconMd - Spacing.xs,
                  height: Spacing.iconMd - Spacing.xs,
                  color: color.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

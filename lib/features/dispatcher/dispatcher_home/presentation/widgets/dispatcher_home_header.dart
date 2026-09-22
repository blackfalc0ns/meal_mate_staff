import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/notification_button.dart';

class DispatcherHomeHeader extends StatelessWidget {
  const DispatcherHomeHeader({
    super.key,
    this.onNotificationTap,
    this.restaurantName,
    this.role,
    this.greeting,
    this.greetingSubtitle,
    this.hasUnreadNotifications = false,
  });

  final VoidCallback? onNotificationTap;
  final String? restaurantName;
  final String? role;
  final String? greeting;
  final String? greetingSubtitle;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: Spacing.iconSm,
                    color: color.onSurface,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: Text(
                      restaurantName?.isNotEmpty == true
                          ? restaurantName!
                          : locale.homeStoreName,
                      style: getSemiBoldStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size10,
                        color: color.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs + Spacing.hairline,
                      vertical: Spacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.homeBadgeBg,
                      borderRadius: BorderRadius.circular(Spacing.radiusXs),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: Spacing.iconXs - 2,
                          color: color.homeBadgeText,
                        ),
                        const SizedBox(width: Spacing.xs / 2),
                        Text(
                          role?.isNotEmpty == true
                              ? role!
                              : locale.homeRoleDispatcher,
                          style: getSemiBoldStyle(
                            fontFamily: FontConstant.alexandria,
                            fontSize: FontSize.size7,
                            color: color.homeBadgeText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.xs),
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.4),
                  width: Spacing.border,
                ),
              ),
              child: NotificationButton(
                hasUnread: hasUnreadNotifications,
                onPressed:
                    onNotificationTap ??
                    () => context.pushNamed(AppRoutes.dispatcherNotifications),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        Text(
          greeting?.isNotEmpty == true ? greeting! : locale.homeGreeting,
          style: getBoldStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size16,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs / 2),
        Text(
          greetingSubtitle?.isNotEmpty == true
              ? greetingSubtitle!
              : locale.homeGreetingSubtitle,
          style: getRegularStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size9,
            color: color.homeMutedText,
          ),
        ),
      ],
    );
  }
}

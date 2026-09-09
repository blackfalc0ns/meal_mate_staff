import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';

class DispatcherMapHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DispatcherMapHeader({
    super.key,
    this.onNotificationTap,
    this.onMenuTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar(
      primary: false,
      showBackButton: false,
      leading: IconButton(
        onPressed: onMenuTap,
        icon: const Icon(Icons.menu_rounded),
      ),
      title: locale.mapDriverTrackingTitle,
      subtitle: locale.mapDriverTrackingSubtitle,
      centerTitle: true,
      actions: [
        NotificationButton(hasUnread: true, onPressed: onNotificationTap),
      ],
    );
  }
}

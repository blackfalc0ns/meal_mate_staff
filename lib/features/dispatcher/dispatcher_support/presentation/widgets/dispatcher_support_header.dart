import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';

class DispatcherSupportHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DispatcherSupportHeader({
    super.key,
    this.onNotificationTap,
    this.onFilterTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar(
      showBackButton: false,
      leading: NotificationButton(
        hasUnread: true,
        onPressed: onNotificationTap,
      ),
      title: locale.supportTitle,
      subtitle: locale.supportSubtitle,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: onFilterTap,
          icon: const Icon(Icons.filter_alt_outlined),
        ),
      ],
    );
  }
}

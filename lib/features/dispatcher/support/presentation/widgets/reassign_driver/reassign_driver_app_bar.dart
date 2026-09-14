import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/widget/custom_app_bar.dart';
import '../../../../../../core/widget/notification_button.dart';

class ReassignDriverAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ReassignDriverAppBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return CustomAppBar(
      title: locale.reassignDriverTitle,
      centerTitle: true,
      backgroundColor: color.surface,
      elevation: Spacing.zero,
      showBackButton: true,
      onBackPressed: onBack ?? () => Navigator.of(context).maybePop(),
      actions: [NotificationButton(hasUnread: true, onPressed: () {})],
    );
  }
}

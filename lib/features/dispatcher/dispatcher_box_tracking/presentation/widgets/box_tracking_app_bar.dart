import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class BoxTrackingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BoxTrackingAppBar({super.key, this.onBack, this.onMore});

  final VoidCallback? onBack;
  final VoidCallback? onMore;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return CustomAppBar(
      showBackButton: true,
      title: locale.boxTrackingTitle,
      backgroundColor: color.surface,
      elevation: Spacing.zero,
      centerTitle: true,
      onBackPressed: onBack,
      actions: [
        IconButton(
          onPressed: onMore,
          icon: const Icon(Icons.more_vert_rounded),
          color: color.onSurface,
          iconSize: Spacing.iconMd,
        ),
      ],
    );
  }
}

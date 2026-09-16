import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverDetailsAppBar({super.key, this.onBack, this.onMore});

  final VoidCallback? onBack;
  final VoidCallback? onMore;

  @override
  Size get preferredSize => const Size.fromHeight(Spacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return CustomAppBar(
      showBackButton: true,
      title: locale.driverDetailsTitle,
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

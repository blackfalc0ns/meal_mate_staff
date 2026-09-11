import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverDetailsAppBar({
    super.key,
    this.onBack,
    this.onMore,
  });

  final VoidCallback? onBack;
  final VoidCallback? onMore;

  @override
  Size get preferredSize => const Size.fromHeight(Spacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppBar(
        backgroundColor: color.surface,
        surfaceTintColor: Colors.transparent,
        elevation: Spacing.zero,
        scrolledUnderElevation: Spacing.zero,
        centerTitle: true,
        leading: IconButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: color.onSurface,
          iconSize: Spacing.iconSm + Spacing.xs / 2,
        ),
        title: Text(
          locale.driverDetailsTitle,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_vert_rounded),
            color: color.onSurface,
            iconSize: Spacing.iconMd,
          ),
          const SizedBox(width: Spacing.xs),
        ],
      ),
    );
  }
}

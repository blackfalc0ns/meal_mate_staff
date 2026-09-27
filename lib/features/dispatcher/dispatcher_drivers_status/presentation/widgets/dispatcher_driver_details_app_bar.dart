import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriverDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DispatcherDriverDetailsAppBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return AppBar(
      elevation: 0,
      backgroundColor: color.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: color.onSurface,
          size: Spacing.iconSm,
        ),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        locale.driverDetailsTitle,
        style: getBoldStyle(color: color.onSurface, fontSize: FontSize.size16),
      ),
    );
  }
}

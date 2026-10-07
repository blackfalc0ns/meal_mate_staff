import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class ReassignmentRequestHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const ReassignmentRequestHeader({
    super.key,
    this.onBackPressed,
    this.showBackButton = false,
  });

  final VoidCallback? onBackPressed;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return AppBar(
      backgroundColor: color.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: Spacing.iconSm,
                color: color.onSurface,
              ),
              onPressed: onBackPressed ?? () => context.maybePopRoute(),
            )
          : null,
      title: Text(
        locale.reassignRequestTitle,
        style: getBoldStyle(
          fontSize: FontSize.size16,
          color: color.onSurface,
        ),
      ),
    );
  }
}

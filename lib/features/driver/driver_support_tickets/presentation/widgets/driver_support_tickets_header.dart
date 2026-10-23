import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class DriverSupportTicketsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverSupportTicketsHeader({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
  });

  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(74.0);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;
    final color = context.colorScheme;

    return CustomAppBar(
      centerTitle: false,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            locale.driverSupportTicketsTitle,
            style: getBoldStyle(
              fontSize: FontSize.size22,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.xs / 2),
          Text(
            locale.driverSupportTicketsSubtitle,
            style: getRegularStyle(
              fontSize: FontSize.size12,
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
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
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar(
      title: locale.driverSupportTicketsTitle,
      subtitle: locale.driverSupportTicketsSubtitle,
      centerTitle: true,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      titleFontSize: FontSize.size20,
    );
  }
}

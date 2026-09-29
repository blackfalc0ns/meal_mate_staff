import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class DriverSupportTicketDetailsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverSupportTicketDetailsHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + Spacing.md);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar(
      title: locale.driverSupportTicketDetailsTitle,
      subtitle: locale.driverSupportTicketDetailsSubtitle,
      titleFontSize: FontSize.size18,
      centerTitle: true,
      showBackButton: true,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class DriverBoxesReceivedHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverBoxesReceivedHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(106.0);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar.logo(
      showBackButton: false,
      title: locale.driverBoxesReceivedTitle,
      subtitle: locale.driverBoxesReceivedSubtitle,
    );
  }
}

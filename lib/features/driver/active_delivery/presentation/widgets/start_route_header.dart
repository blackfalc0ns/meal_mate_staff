import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class StartRouteHeader extends StatelessWidget implements PreferredSizeWidget {
  const StartRouteHeader({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(84.0);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar.withSubtitle(
      title: locale.driverStartDeliveryRouteTitle,
      subtitle: locale.driverStartDeliveryRouteSubtitle,
      showBackButton: true,
      onBackPressed: onBackPressed,
    );
  }
}

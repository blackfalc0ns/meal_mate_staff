import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class DeliveryDelayHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DeliveryDelayHeader({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar.simple(
      title: locale.driverDeliveryDelayTitle,
      showBackButton: true,
      onBackPressed: onBackPressed,
    );
  }
}

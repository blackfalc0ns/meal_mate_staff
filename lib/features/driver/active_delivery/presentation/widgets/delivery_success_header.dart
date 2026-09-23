import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class DeliverySuccessHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DeliverySuccessHeader({super.key, this.onClosePressed});

  final VoidCallback? onClosePressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return CustomAppBar.simple(
      title: locale.driverDeliverySuccessTitle,
      showBackButton: true,
      onBackPressed: onClosePressed,
    );
  }
}

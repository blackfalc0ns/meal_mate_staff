import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class DriverTrackingAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverTrackingAppBar({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(Spacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar.logo(
      showBackButton: true,
      onBackPressed: onBackPressed,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/widget/custom_app_bar.dart';

class DriverVehicleHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverVehicleHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(106.0);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar.logo(
      title: title,
      subtitle: subtitle,
      onBackPressed: onBack,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../orders/presentation/widgets/driver_boxes_header_logo.dart';

class DriverTrackingAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverTrackingAppBar({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(Spacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return CustomAppBar(
      backgroundColor: color.surface,
      centerTitle: true,
      titleWidget: const DriverBoxesHeaderLogo(),
      showBackButton: true,
      onBackPressed: onBackPressed,
    );
  }
}

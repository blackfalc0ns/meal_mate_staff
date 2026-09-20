import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../orders/presentation/widgets/driver_boxes_header_logo.dart';

class DriverNotificationsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverNotificationsHeader({super.key, this.onBack, this.onSettingsTap});

  final VoidCallback? onBack;
  final VoidCallback? onSettingsTap;

  @override
  Size get preferredSize => const Size.fromHeight(Spacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final shouldShowBack = canPop || onBack != null;

    return CustomAppBar(
      title: locale.driverNotificationsTitle,
      centerTitle: true,
      backgroundColor: color.surface,
      showBackButton: shouldShowBack,
      onBackPressed: onBack,
      leading: shouldShowBack
          ? null
          : const Center(child: DriverBoxesHeaderLogo()),
      actions: [
        IconButton(
          onPressed: onSettingsTap,
          icon: Icon(
            Icons.settings_outlined,
            color: color.onSurfaceVariant,
            size: Spacing.iconMd,
          ),
        ),
        const SizedBox(width: Spacing.xs),
      ],
    );
  }
}

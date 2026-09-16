import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import 'driver_performance_date_filter_chip.dart';

class DriverPerformanceHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DriverPerformanceHeader({
    super.key,
    this.onBack,
    this.onDateFilterTap,
  });

  final VoidCallback? onBack;
  final VoidCallback? onDateFilterTap;

  @override
  Size get preferredSize => const Size.fromHeight(Spacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return CustomAppBar(
      primary: false,
      showBackButton: false,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: Spacing.sm),
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: Spacing.iconSm,
              color: color.onSurface,
            ),
            onPressed: onBack ??
                () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
          ),
        ),
      ),
      titleWidget: Text(
        locale.driverPerformanceTitle,
        style: getBoldStyle(
          fontFamily: FontConstant.alexandria,
          fontSize: FontSize.size18,
          color: color.onSurface,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: Spacing.base),
          child: Center(
            child: DriverPerformanceDateFilterChip(
              onTap: onDateFilterTap,
            ),
          ),
        ),
      ],
    );
  }
}

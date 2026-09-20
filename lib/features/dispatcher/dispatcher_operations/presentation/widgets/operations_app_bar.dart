import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';

class OperationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OperationsAppBar({super.key, this.onBackPressed, this.onFilterTap});

  final VoidCallback? onBackPressed;
  final VoidCallback? onFilterTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return CustomAppBar(
      title: locale.operationsTitle,
      centerTitle: true,
      showBackButton: true,
      onBackPressed: onBackPressed,
      actions: [
        if (onFilterTap != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: Spacing.base),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs,
                  vertical: Spacing.xs / 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.operationsFilter,
                      style: getBoldStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size13,
                        color: color.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 18,
                      color: color.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

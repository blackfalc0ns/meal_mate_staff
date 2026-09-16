import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import 'dispatcher_drivers_header_action_button.dart';

class DispatcherDriversHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DispatcherDriversHeader({super.key, this.onBack, this.onFilter});

  final VoidCallback? onBack;
  final VoidCallback? onFilter;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return CustomAppBar(
      primary: false,
      showBackButton: false,
      centerTitle: false,
      subtitle: locale.driversSubtitle,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: Spacing.base),
        child: Center(
          child: DispatcherDriversHeaderActionButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap:
                onBack ??
                () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
          ),
        ),
      ),
      titleWidget: Padding(
        padding: const EdgeInsetsDirectional.only(start: Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.driversTitle,
              style: getBoldStyle(
                fontSize: FontSize.size18,
                color: color.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              locale.driversSubtitle,
              style: getRegularStyle(
                fontSize: FontSize.size12,
                color: color.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: Spacing.base),
          child: Center(
            child: DispatcherDriversHeaderActionButton(
              icon: Icons.tune_rounded,
              onTap: onFilter,
            ),
          ),
        ),
      ],
    );
  }
}

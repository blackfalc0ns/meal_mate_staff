import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import 'dispatcher_drivers_header_action_button.dart';

class DispatcherDriversHeader extends StatelessWidget {
  const DispatcherDriversHeader({
    super.key,
    this.onBack,
    this.onFilter,
  });

  final VoidCallback? onBack;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          DispatcherDriversHeaderActionButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack ??
                () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
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
          const SizedBox(width: Spacing.sm),
          DispatcherDriversHeaderActionButton(
            icon: Icons.tune_rounded,
            onTap: onFilter,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherTitleSection extends StatelessWidget {
  const DispatcherTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.dispatcherOrdersTitle,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size15,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.dispatcherOrdersSubtitle,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size12,
            ),
          ),
        ],
      ),
    );
  }
}

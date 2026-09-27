import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusEmptyState extends StatelessWidget {
  const DispatcherDriversStatusEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.all(Spacing.xxl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: Spacing.iconLg + Spacing.md,
              color: color.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              locale.driversStatusEmpty,
              style: getMediumStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size14,
                color: color.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

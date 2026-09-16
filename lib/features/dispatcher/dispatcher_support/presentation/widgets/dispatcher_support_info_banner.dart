import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherSupportInfoBanner extends StatelessWidget {
  const DispatcherSupportInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_rounded,
              size: Spacing.iconSm,
              color: color.primary,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Text(
                locale.supportInfoBannerText,
                style: getRegularStyle(
                  fontSize: FontSize.size10,
                  color: color.primary,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class BoxTrackingReportIssueButton extends StatelessWidget {
  const BoxTrackingReportIssueButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Container(
        height: Spacing.buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Spacing.lg,
              height: Spacing.lg,
              decoration: BoxDecoration(
                color: color.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_rounded,
                size: Spacing.iconXs,
                color: color.onError,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Flexible(
              child: Text(
                locale.boxTrackingReportIssue,
                style: getBoldStyle(
                  color: color.error,
                  fontSize: FontSize.size14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportAttachmentBox extends StatelessWidget {
  const DriverSupportAttachmentBox({
    super.key,
    this.attachedFileName,
    this.onTap,
    this.onRemove,
  });

  final String? attachedFileName;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    if (attachedFileName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.primary.withValues(alpha: 0.3),
            width: Spacing.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              color: color.primary,
              size: Spacing.iconMd,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                locale.driverSupportAttachmentSelected(attachedFileName!),
                style: getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size12,
                  color: color.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onRemove != null)
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: color.onSurfaceVariant,
                  size: 18,
                ),
                onPressed: onRemove,
                splashRadius: 18,
              ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.primary.withValues(alpha: 0.25),
            width: Spacing.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  color: color.primary,
                  size: 18,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driverSupportAddAttachment,
                  style: getMediumStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size13,
                    color: color.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              locale.driverSupportAttachmentHint,
              style: getRegularStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size11,
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

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
          horizontal: Spacing.sm + 2,
          vertical: Spacing.xs + 2,
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
              size: 16,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Text(
                locale.driverSupportAttachmentSelected(attachedFileName!),
                style: getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size11,
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
                  size: 16,
                ),
                onPressed: onRemove,
                splashRadius: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
          horizontal: Spacing.sm,
          vertical: Spacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.primary.withValues(alpha: 0.3),
            width: Spacing.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file_rounded, color: color.primary, size: 16),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driverSupportAddAttachment,
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size11,
                    color: color.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              locale.driverSupportAttachmentHint,
              style: getRegularStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size9,
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


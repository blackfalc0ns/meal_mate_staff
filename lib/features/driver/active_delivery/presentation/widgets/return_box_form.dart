import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class ReturnBoxForm extends StatelessWidget {
  const ReturnBoxForm({
    super.key,
    this.note,
    this.attachmentPath,
    this.onAttachImagePressed,
  });

  final String? note;
  final String? attachmentPath;
  final VoidCallback? onAttachImagePressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note != null && note!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(color: color.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.driverAdditionalNotesLabel,
                  style: getSemiBoldStyle(
                    fontSize: FontSize.size12,
                    color: color.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  note!,
                  style: getRegularStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.base),
        ],
        InkWell(
          onTap: onAttachImagePressed,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.lg,
            ),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(
                color: color.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: Spacing.iconLg,
                  color: color.primary,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.driverAttachImageLabel,
                  style: getMediumStyle(
                    fontSize: FontSize.size13,
                    color: color.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

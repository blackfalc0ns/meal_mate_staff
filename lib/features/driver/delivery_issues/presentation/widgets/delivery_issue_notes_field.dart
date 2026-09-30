import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliveryIssueNotesField extends StatelessWidget {
  const DeliveryIssueNotesField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  static const int maxLength = 250;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          locale.reportIssueNotesTitle,
          style: getBoldStyle(
            fontSize: FontSize.size14,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.reportIssueNotesSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final currentLength = value.text.length;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: color.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.5),
                  width: Spacing.border,
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    maxLength: maxLength,
                    maxLines: 4,
                    minLines: 3,
                    onChanged: onChanged,
                    style: getRegularStyle(
                      fontSize: FontSize.size13,
                      color: color.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: locale.reportIssueNotesHint,
                      hintStyle: getRegularStyle(
                        fontSize: FontSize.size13,
                        color: color.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(Spacing.md),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: Spacing.xs,
                      left: Spacing.sm,
                      right: Spacing.sm,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '$currentLength/$maxLength',
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

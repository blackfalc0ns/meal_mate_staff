import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class ReassignmentNotesField extends StatelessWidget {
  const ReassignmentNotesField({
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

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final currentLength = value.text.length;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.7),
              width: 1.0,
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
                  fontSize: FontSize.size14,
                  color: color.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: locale.reassignRequestNotesHint,
                  hintStyle: getRegularStyle(
                    fontSize: FontSize.size14,
                    color: color.onSurfaceVariant.withValues(alpha: 0.55),
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
    );
  }
}

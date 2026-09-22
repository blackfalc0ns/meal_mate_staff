import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportMessageInput extends StatelessWidget {
  const DriverSupportMessageInput({
    super.key,
    required this.controller,
    this.maxLength = 500,
  });

  final TextEditingController controller;
  final int maxLength;

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
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.6),
              width: Spacing.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 5,
                minLines: 4,
                maxLength: maxLength,
                buildCounter:
                    (
                      _, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                style: getRegularStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size13,
                  color: color.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: locale.driverSupportMessageDetailsHint,
                  hintStyle: getRegularStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size13,
                    color: color.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(Spacing.base),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base,
                  vertical: Spacing.xs,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '$currentLength/$maxLength',
                    style: getRegularStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
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

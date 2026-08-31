import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/l10n/translations/app_localizations.dart';

class RegisterPlateNumberField extends StatelessWidget {
  const RegisterPlateNumberField({super.key, required this.locale});

  final AppLocalizations locale;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SizedBox(
      height: Spacing.registrationFieldHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            locale.registrationPlateNumber,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size12,
              height: 1.2,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
             
              Expanded(
                child: SizedBox(
                  height: Spacing.registrationFieldInputHeight,
                  child: TextFormField(
                    textAlign: TextAlign.start,
                    style: getRegularStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                    ),
                    decoration: InputDecoration(
                      hintText: locale.registrationPlateNumberHint,
                      hintStyle: getMediumStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),

               SizedBox(
                width: 110,
                height: Spacing.registrationFieldInputHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.surface,
                    border: Border.all(color: color.outline),
                    borderRadius: BorderRadius.circular(
                      Spacing.registrationRadius,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_circle_rounded,
                          color: color.onSurfaceVariant,
                          size: Spacing.iconMd,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          locale.registrationKuwait,
                          style: getBoldStyle(
                            color: color.onSurface,
                            fontSize: FontSize.size13,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

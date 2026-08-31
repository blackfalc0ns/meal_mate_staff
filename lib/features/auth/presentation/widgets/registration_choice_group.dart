import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationChoiceGroup extends StatelessWidget {
  const RegistrationChoiceGroup({
    super.key,
    required this.label,
    required this.firstText,
    required this.secondText,
    this.firstSelected = true,
    this.onFirstTap,
    this.onSecondTap,
  });

  final String label;
  final String firstText;
  final String secondText;
  final bool firstSelected;
  final VoidCallback? onFirstTap;
  final VoidCallback? onSecondTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size13,
            height: 1.2,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Expanded(
              child: _choice(context, firstText, firstSelected, onFirstTap),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: _choice(context, secondText, !firstSelected, onSecondTap),
            ),
          ],
        ),
      ],
    );
  }

  Widget _choice(
    BuildContext context,
    String text,
    bool selected,
    VoidCallback? onTap,
  ) {
    final color = context.colorScheme;

    return SizedBox(
      height: Spacing.registrationFieldInputHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.registrationRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.surface,
            border: Border.all(color: selected ? color.primary : color.outline),
            borderRadius: BorderRadius.circular(Spacing.registrationRadius),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: selected ? color.primary : color.onSurfaceVariant,
                  size: Spacing.iconMd,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  text,
                  style: getBoldStyle(
                    color: selected ? color.primary : color.onSurfaceVariant,
                    fontSize: FontSize.size13,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

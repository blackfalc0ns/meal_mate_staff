import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationReviewSection extends StatelessWidget {
  const RegistrationReviewSection({
    super.key,
    required this.title,
    required this.children,
    this.actionText,
  });

  final String title;
  final String? actionText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(Spacing.registrationReviewCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                      height: 1.2,
                    ),
                  ),
                ),
                if (actionText != null)
                  Text(
                    actionText!,
                    style: getRegularStyle(
                      color: color.primary,
                      fontSize: FontSize.size10,
                      height: 1.2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

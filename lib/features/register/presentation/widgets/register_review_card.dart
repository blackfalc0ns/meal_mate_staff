import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegisterReviewCard extends StatelessWidget {
  const RegisterReviewCard({
    super.key,
    required this.title,
    required this.children,
    required this.onEdit,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(
          Spacing.registrationReviewCardRadius,
        ),
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
                    textAlign: TextAlign.start,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: color.primary,
                    size: Spacing.iconSm,
                  ),
                  label: Text(
                    locale.registrationEdit,
                    style: getRegularStyle(
                      color: color.primary,
                      fontSize: FontSize.size10,
                      height: 1.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(
                      Spacing.xxxl,
                      Spacing.registrationSmallButtonHeight,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                    side: BorderSide(color: color.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Spacing.registrationRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Wrap(runSpacing: Spacing.md, children: children),
          ],
        ),
      ),
    );
  }
}

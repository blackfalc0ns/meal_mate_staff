import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class ReassignmentSubmittedCard extends StatelessWidget {
  const ReassignmentSubmittedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AppAssets.reassignmentSubmittedIllustration,
          width: 250,
          height: 190,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          locale.reassignSubmittedTitle,
          style: getBoldStyle(
            fontSize: FontSize.size22,
            color: color.onSurface,
            height: 1.35,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.md),
        Text(
          locale.reassignSubmittedSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size14,
            color: color.onSurfaceVariant.withValues(alpha: 0.85),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

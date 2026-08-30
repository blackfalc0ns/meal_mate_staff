import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/text_styles.dart';

class CustomWarningWidget extends StatelessWidget {
  const CustomWarningWidget({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.warning_amber_rounded,
  });

  final String? title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        border: Border.all(color: AppColors.warning),
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.base),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.warning),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(title!, style: AppTextStyles.labelLarge),
                  Text(message, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

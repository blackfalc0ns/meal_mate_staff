import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationReviewItem extends StatelessWidget {
  const RegistrationReviewItem({
    super.key,
    required this.label,
    required this.value,
    this.isUploaded = false,
  });

  final String label;
  final String value;
  final bool isUploaded;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: getSemiBoldStyle(
                color: isUploaded ? color.tertiary : color.onSurface,
                fontSize: FontSize.size10,
                height: 1.3,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              label,
              style: getRegularStyle(
                color: color.onSurfaceVariant,
                fontSize: FontSize.size10,
                height: 1.3,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliveryIssueNoticeBanner extends StatelessWidget {
  const DeliveryIssueNoticeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.error.withValues(alpha: 0.3),
          width: Spacing.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: Spacing.iconSm,
            color: color.error,
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              locale.reportIssueOperationalWarning,
              style: getRegularStyle(
                fontSize: FontSize.size11,
                color: color.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverCallHeader extends StatelessWidget {
  const DriverCallHeader({
    super.key,
    required this.customerName,
    required this.durationText,
  });

  final String customerName;
  final String durationText;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Spacing.xs * 1.5,
              height: Spacing.xs * 1.5,
              decoration: BoxDecoration(
                color: color.tertiary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              locale.driverCallInProgress,
              style: getRegularStyle(
                fontSize: FontSize.size12,
                color: color.onPrimary.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          customerName,
          style: getBoldStyle(
            fontSize: FontSize.size22,
            color: color.onPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          durationText,
          style: getMediumStyle(
            fontSize: FontSize.size14,
            color: color.onPrimary.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

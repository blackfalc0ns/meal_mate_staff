import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversCardMetricItem extends StatelessWidget {
  const DispatcherDriversCardMetricItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Spacing.iconXs,
              color: iconColor,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                value,
                style: getBoldStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.border + Spacing.border),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: getRegularStyle(
              fontSize: FontSize.size10,
              color: color.onSurfaceVariant,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

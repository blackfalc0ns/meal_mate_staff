import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversCardMetricItem extends StatelessWidget {
  const DispatcherDriversCardMetricItem({
    super.key,
    this.icon,
    this.iconColor,
    this.assetPath,
    required this.value,
    required this.label,
  });

  final IconData? icon;
  final Color? iconColor;
  final String? assetPath;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      height: Spacing.dispatcherMetricBoxHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.border,
      ),
      decoration: BoxDecoration(
        color: color.dispatcherMetricBoxSurface,
        borderRadius: BorderRadius.circular(
          Spacing.registrationReviewCardRadius,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (assetPath != null)
                  Image.asset(
                    assetPath!,
                    width: Spacing.dispatcherMetricIconSize,
                    height: Spacing.dispatcherMetricIconSize,
                  )
                else if (icon != null)
                  Icon(
                    icon,
                    size: Spacing.dispatcherMetricIconSize,
                    color: iconColor,
                  ),
                const SizedBox(width: Spacing.border * 2),
                Text(
                  value,
                  style: getBoldStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.border),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: getRegularStyle(
                fontSize: FontSize.size9,
                color: color.onSurfaceVariant,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

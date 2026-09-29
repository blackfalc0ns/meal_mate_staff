import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformanceSummaryColumn extends StatelessWidget {
  const DriverPerformanceSummaryColumn({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.unit,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: getRegularStyle(
            fontSize: FontSize.size10,
            color: color.onInverseSurface.withValues(alpha: 0.85),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: getRegularStyle(
              fontSize: FontSize.size9,
              color: color.onInverseSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: Spacing.xs),
        Icon(
          icon,
          size: 20,
          color: color.onInverseSurface,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: getBoldStyle(
            fontSize: FontSize.size16,
            color: color.onInverseSurface,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: getRegularStyle(
            fontSize: FontSize.size10,
            color: color.onInverseSurface.withValues(alpha: 0.85),
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

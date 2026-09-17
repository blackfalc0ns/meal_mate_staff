import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxesReceivedSummaryItem extends StatelessWidget {
  const DriverBoxesReceivedSummaryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Spacing.iconSm,
            color: color.onSurfaceVariant,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class BoxTrackingDetailsRow extends StatelessWidget {
  const BoxTrackingDetailsRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: Spacing.iconSm,
            color: color.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.xs),
        ],
        Text(
          label,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size13,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: getSemiBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

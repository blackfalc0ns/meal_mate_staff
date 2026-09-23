import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxReceivedDetailRow extends StatelessWidget {
  const DriverBoxReceivedDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  static const double _iconBoxSize = 36;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      children: [
        Container(
          width: _iconBoxSize,
          height: _iconBoxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
          ),
          child: Icon(
            icon,
            size: Spacing.iconSm,
            color: color.primary,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                value,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

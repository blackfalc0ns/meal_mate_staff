import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxesReceivedSuccessBanner extends StatelessWidget {
  const DriverBoxesReceivedSuccessBanner({super.key});

  static const double _iconSize = 36;
  static const double _iconInner = 22;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.tertiaryContainer,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _iconSize,
            height: _iconSize,
            decoration: BoxDecoration(
              color: color.tertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: color.onTertiary,
              size: _iconInner,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            locale.driverBoxesReceivedSuccessCount,
            style: getBoldStyle(
              color: color.tertiary,
              fontSize: FontSize.size16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.driverBoxesReceivedReadySub,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

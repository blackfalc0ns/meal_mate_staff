import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class AssignBoxDriverAvatar extends StatelessWidget {
  const AssignBoxDriverAvatar({
    super.key,
    this.badgeNumber,
    this.size = Spacing.buttonSmallHeight,
  });

  final String? badgeNumber;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.surface,
            border: Border.all(
              color: color.primary,
              width: Spacing.border,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: Spacing.iconMd,
              color: color.primary,
            ),
          ),
        ),
        if (badgeNumber != null)
          PositionedDirectional(
            bottom: -Spacing.xs,
            start: -Spacing.xs,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.zero,
              ),
              decoration: BoxDecoration(
                color: color.primary,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
              ),
              child: Text(
                badgeNumber!,
                style: getSemiBoldStyle(
                  color: color.onPrimary,
                  fontSize: FontSize.size9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

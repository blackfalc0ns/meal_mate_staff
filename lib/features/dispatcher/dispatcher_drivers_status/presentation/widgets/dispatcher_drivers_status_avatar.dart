import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusAvatar extends StatelessWidget {
  const DispatcherDriversStatusAvatar({
    super.key,
    required this.avatarUrl,
  });

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SizedBox(
      width: Spacing.xxl + Spacing.sm,
      height: Spacing.xxl + Spacing.sm,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: (Spacing.xxl + Spacing.sm) / 2,
            backgroundColor: color.outlineVariant.withValues(alpha: 0.3),
            backgroundImage: AssetImage(avatarUrl),
          ),
          PositionedDirectional(
            bottom: Spacing.zero,
            start: Spacing.zero,
            child: Container(
              padding: const EdgeInsets.all(Spacing.border),
              decoration: BoxDecoration(
                color: color.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.surface,
                  width: Spacing.border,
                ),
              ),
              child: Icon(
                Icons.directions_bike_rounded,
                size: Spacing.iconXs - 4,
                color: color.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

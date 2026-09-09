import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversHeaderActionButton extends StatelessWidget {
  const DispatcherDriversHeaderActionButton({
    super.key,
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusSm),
      child: Container(
        width: Spacing.xxl + Spacing.xs,
        height: Spacing.xxl + Spacing.xs,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: Spacing.hairline),
          ),
        ),
        child: Icon(
          icon,
          size: Spacing.iconSm + Spacing.border + Spacing.border,
          color: color.onSurface,
        ),
      ),
    );
  }
}

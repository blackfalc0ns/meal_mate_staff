import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverProfileQuickActionItem extends StatelessWidget {
  const DriverProfileQuickActionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  static const double _iconSize = 16.0;
  static const double _chevronSize = 9.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs + 2,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: _iconSize,
              color: color.primary,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      title,
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      subtitle,
                      style: getRegularStyle(
                        fontSize: FontSize.size9,
                        color: color.onSurfaceVariant,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isRtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: _chevronSize,
              color: color.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

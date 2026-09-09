import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherSupportAreaCard extends StatelessWidget {
  const DispatcherSupportAreaCard({
    super.key,
    required this.area,
    this.onTap,
  });

  final String area;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
      child: Container(
        height: Spacing.dispatcherSupportKpiCardHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: Spacing.iconSm,
              color: color.onSurface,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    locale.supportCurrentArea,
                    style: getRegularStyle(
                      fontSize: FontSize.size9,
                      color: color.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.border),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      area,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.primary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

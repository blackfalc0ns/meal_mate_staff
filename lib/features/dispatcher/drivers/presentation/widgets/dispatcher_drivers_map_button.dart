import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversMapButton extends StatelessWidget {
  const DispatcherDriversMapButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        child: Container(
          width: double.infinity,
          height: Spacing.dispatcherMapButtonHeight,
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: Spacing.iconSm,
                color: color.onSurface,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driversViewOnMap,
                style: getMediumStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherMapControls extends StatelessWidget {
  const DispatcherMapControls({
    super.key,
    this.onLocationTap,
    this.onZoomInTap,
    this.onZoomOutTap,
  });

  final VoidCallback? onLocationTap;
  final VoidCallback? onZoomInTap;
  final VoidCallback? onZoomOutTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onLocationTap,
          borderRadius: BorderRadius.circular(Spacing.dispatcherMapControlBtnSize),
          child: Container(
            width: Spacing.dispatcherMapControlBtnSize,
            height: Spacing.dispatcherMapControlBtnSize,
            decoration: BoxDecoration(
              color: color.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.shadow.withValues(alpha: 0.1),
                  blurRadius: Spacing.xs,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.my_location_rounded,
              size: Spacing.iconSm,
              color: color.primary,
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          width: Spacing.dispatcherMapZoomWidth,
          height: Spacing.dispatcherMapZoomHeight,
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
            boxShadow: [
              BoxShadow(
                color: color.shadow.withValues(alpha: 0.1),
                blurRadius: Spacing.xs,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onZoomInTap,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(Spacing.radiusPill),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: Spacing.iconXs,
                      color: color.primary,
                    ),
                  ),
                ),
              ),
              Container(
                width: Spacing.dispatcherMapZoomWidth - Spacing.sm,
                height: Spacing.border,
                color: color.outlineVariant.withValues(alpha: 0.6),
              ),
              Expanded(
                child: InkWell(
                  onTap: onZoomOutTap,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(Spacing.radiusPill),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.remove_rounded,
                      size: Spacing.iconXs,
                      color: color.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

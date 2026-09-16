import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';

class DriverQrHeaderSection extends StatelessWidget {
  const DriverQrHeaderSection({
    super.key,
    required this.isFlashOn,
    required this.onFlashChanged,
  });

  final bool isFlashOn;
  final ValueChanged<bool> onFlashChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Flash toggle pill on the start/left
        InkWell(
          onTap: () => onFlashChanged(!isFlashOn),
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm + 2,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: isFlashOn
                  ? color.primaryContainer
                  : color.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
              border: Border.all(
                color: isFlashOn
                    ? color.primary
                    : color.outlineVariant.withValues(alpha: 0.5),
                width: Spacing.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  size: Spacing.iconSm,
                  color: isFlashOn ? color.primary : color.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driverFlashToggle,
                  style: getSemiBoldStyle(
                    color: isFlashOn ? color.primary : color.onSurface,
                    fontSize: FontSize.size11,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                SizedBox(
                  height: 18,
                  width: 32,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Switch.adaptive(
                      value: isFlashOn,
                      onChanged: onFlashChanged,
                      activeThumbColor: color.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Title and description on the end/right
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locale.driverQrScannerTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size18,
                ),
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: Spacing.hairline * 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      locale.driverQrScannerSubtitle,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

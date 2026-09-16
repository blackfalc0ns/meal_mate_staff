import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

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
        // Title and description on the start (Right in RTL)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locale.driverQrScannerTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size18,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: Spacing.hairline * 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: Text(
                      locale.driverQrScannerSubtitle,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.sm),

        // Flash toggle pill on the end (Left in RTL)
        InkWell(
          onTap: () => onFlashChanged(!isFlashOn),
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm + 4,
              vertical: Spacing.xs + 1,
            ),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
              border: Border.all(
                color: color.outline.withValues(alpha: 0.25),
                width: Spacing.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: Spacing.iconSm + 4,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.hairline * 4),
                Text(
                  locale.driverFlashToggle,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size12,
                  ),
                ),
                const SizedBox(width: Spacing.sm + 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 38,
                  height: 20,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: isFlashOn
                        ? color.primary
                        : color.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  ),
                  alignment: isFlashOn
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

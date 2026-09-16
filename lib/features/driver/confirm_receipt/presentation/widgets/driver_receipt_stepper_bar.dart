import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverReceiptStepperBar extends StatelessWidget {
  const DriverReceiptStepperBar({
    super.key,
    required this.currentStep,
  });

  /// 1 for QR Scanner, 2 for Camera Box Capture
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.xs),
          decoration: BoxDecoration(
            color: color.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStepItem(
                  stepNumber: 1,
                  title: locale.driverStepScanQr,
                  icon: Icons.qr_code_scanner_rounded,
                  isActive: currentStep == 1,
                  color: color,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: _buildStepItem(
                  stepNumber: 2,
                  title: locale.driverStepPhotographBox,
                  icon: Icons.camera_alt_outlined,
                  isActive: currentStep == 2,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs + 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: Spacing.iconXs,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                locale.driverStepOrderMandatoryNote,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required IconData icon,
    required bool isActive,
    required ColorScheme color,
  }) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.sm,
          horizontal: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.primary,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Spacing.iconSm + 4,
              height: Spacing.iconSm + 4,
              decoration: BoxDecoration(
                color: color.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: getBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                title,
                style: getBoldStyle(
                  color: color.onPrimary,
                  fontSize: FontSize.size12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(
              icon,
              size: Spacing.iconSm,
              color: color.onPrimary,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.sm,
        horizontal: Spacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.iconSm + 4,
            height: Spacing.iconSm + 4,
            decoration: BoxDecoration(
              color: color.outlineVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: getBoldStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size10,
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              title,
              style: getMediumStyle(
                color: color.onSurfaceVariant,
                fontSize: FontSize.size12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Icon(
            icon,
            size: Spacing.iconSm,
            color: color.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

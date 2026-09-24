import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverTrackingBottomActions extends StatelessWidget {
  const DriverTrackingBottomActions({
    super.key,
    required this.onConfirmArrival,
    required this.onReportDelay,
    required this.onReportFailed,
    this.isLoading = false,
  });

  final VoidCallback onConfirmArrival;
  final VoidCallback onReportDelay;
  final VoidCallback onReportFailed;
  final bool isLoading;

  static const double _buttonHeight = 46.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirmArrival,
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          locale.driverConfirmArrivalToCustomerAction,
                          style: getBoldStyle(
                            fontSize: FontSize.size14,
                            color: color.onPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: Spacing.iconSm,
                        color: color.onPrimary,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: onReportDelay,
              icon: Icon(
                Icons.access_time,
                size: Spacing.iconXs,
                color: color.onSurfaceVariant,
              ),
              label: Text(
                locale.driverReportDelayButton,
                style: getRegularStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
            Container(
              height: 12,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              color: color.outlineVariant,
            ),
            TextButton.icon(
              onPressed: onReportFailed,
              icon: Icon(
                Icons.cancel_outlined,
                size: Spacing.iconXs,
                color: color.error,
              ),
              label: Text(
                locale.driverReportFailedButton,
                style: getRegularStyle(
                  fontSize: FontSize.size11,
                  color: color.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Spacing.buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirmArrival,
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.buttonRadius),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: Spacing.iconMd,
                        color: color.onPrimary,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Flexible(
                        child: Text(
                          locale.driverConfirmArrivalAction,
                          style: getSemiBoldStyle(
                            fontSize: FontSize.size16,
                            color: color.onPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: Spacing.buttonSmallHeight,
                child: OutlinedButton.icon(
                  onPressed: onReportDelay,
                  icon: Icon(
                    Icons.access_time,
                    size: Spacing.iconSm,
                    color: color.secondary,
                  ),
                  label: Text(
                    locale.driverReportDelayButton,
                    style: getMediumStyle(
                      fontSize: FontSize.size13,
                      color: color.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Spacing.buttonSmallRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: SizedBox(
                height: Spacing.buttonSmallHeight,
                child: OutlinedButton.icon(
                  onPressed: onReportFailed,
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: Spacing.iconSm,
                    color: color.error,
                  ),
                  label: Text(
                    locale.driverReportFailedButton,
                    style: getMediumStyle(
                      fontSize: FontSize.size13,
                      color: color.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Spacing.buttonSmallRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

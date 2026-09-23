import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class FailedDeliveryActions extends StatelessWidget {
  const FailedDeliveryActions({
    super.key,
    required this.onSubmit,
    required this.onRetry,
    this.isLoading = false,
  });

  final VoidCallback onSubmit;
  final VoidCallback onRetry;
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
            onPressed: isLoading ? null : onSubmit,
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
                        Icons.send,
                        size: Spacing.iconMd,
                        color: color.onPrimary,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Flexible(
                        child: Text(
                          locale.driverSendReportAction,
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
        SizedBox(
          height: Spacing.buttonHeight,
          child: OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: color.primary,
              side: BorderSide(color: color.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.buttonRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: Spacing.iconMd, color: color.primary),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: Text(
                    locale.driverRetryDelivery,
                    style: getSemiBoldStyle(
                      fontSize: FontSize.size16,
                      color: color.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

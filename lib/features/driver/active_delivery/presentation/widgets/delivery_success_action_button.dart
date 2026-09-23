import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliverySuccessActionButton extends StatelessWidget {
  const DeliverySuccessActionButton({
    super.key,
    required this.onConfirmed,
    this.onBackToOrders,
    this.isLoading = false,
  });

  final VoidCallback onConfirmed;
  final VoidCallback? onBackToOrders;
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
            onPressed: isLoading ? null : onConfirmed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.buttonRadius),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: Spacing.iconMd, color: color.onPrimary),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: Text(
                    locale.driverReceiptConfirmedAction,
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
        if (onBackToOrders != null) ...[
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: Spacing.buttonHeight,
            child: OutlinedButton(
              onPressed: onBackToOrders,
              style: OutlinedButton.styleFrom(
                foregroundColor: color.primary,
                side: BorderSide(color: color.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.buttonRadius),
                ),
              ),
              child: Text(
                locale.driverBackToOrdersAction,
                style: getSemiBoldStyle(
                  fontSize: FontSize.size16,
                  color: color.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

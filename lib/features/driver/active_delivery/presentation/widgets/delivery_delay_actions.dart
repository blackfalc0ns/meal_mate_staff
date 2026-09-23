import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliveryDelayActions extends StatelessWidget {
  const DeliveryDelayActions({
    super.key,
    required this.onContinueDelivery,
    required this.onContactSupport,
  });

  final VoidCallback onContinueDelivery;
  final VoidCallback onContactSupport;

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
            onPressed: onContinueDelivery,
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
                Icon(
                  Icons.navigation,
                  size: Spacing.iconMd,
                  color: color.onPrimary,
                ),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: Text(
                    locale.driverContinueDeliveryAction,
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
            onPressed: onContactSupport,
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
                Icon(
                  Icons.support_agent,
                  size: Spacing.iconMd,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: Text(
                    locale.driverContactSupportAction,
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

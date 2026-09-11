import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DriverDetailsActionButtons extends StatelessWidget {
  const DriverDetailsActionButtons({
    super.key,
    this.onSendMessage,
    this.onCall,
  });

  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          // 1. Send message button (Right in RTL)
          Expanded(
            child: AppButton(
              text: locale.driverDetailsSendMessage,
              onPressed: onSendMessage,
              variant: AppButtonVariant.filled,
              color: color.primary,
              textColor: color.onPrimary,
              height: Spacing.dispatcherActionBtnSmallHeight,
              borderRadius: Spacing.buttonSmallRadius,
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.xs,
                horizontal: Spacing.xs,
              ),
              iconWidget: SvgPicture.asset(
                AppAssets.driverActionMsg,
                width: Spacing.iconXs,
                height: Spacing.iconXs,
                colorFilter: ColorFilter.mode(
                  color.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
              iconGap: Spacing.xs,
              textStyle: getSemiBoldStyle(
                color: color.onPrimary,
                fontSize: FontSize.size12,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // 2. Call button (Left in RTL)
          Expanded(
            child: AppButton(
              text: locale.driverDetailsCall,
              onPressed: onCall,
              variant: AppButtonVariant.outlined,
              color: color.primary,
              textColor: color.primary,
              height: Spacing.dispatcherActionBtnSmallHeight,
              borderRadius: Spacing.buttonSmallRadius,
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.xs,
                horizontal: Spacing.xs,
              ),
              iconWidget: SvgPicture.asset(
                AppAssets.driverActionCall,
                width: Spacing.iconXs,
                height: Spacing.iconXs,
                colorFilter: ColorFilter.mode(
                  color.primary,
                  BlendMode.srcIn,
                ),
              ),
              iconGap: Spacing.xs,
              textStyle: getSemiBoldStyle(
                color: color.primary,
                fontSize: FontSize.size12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

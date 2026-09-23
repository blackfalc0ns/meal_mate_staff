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
    this.onSelectSms,
    this.onSelectWhatsApp,
    this.onCall,
  });

  final VoidCallback? onSendMessage;
  final VoidCallback? onSelectSms;
  final VoidCallback? onSelectWhatsApp;
  final VoidCallback? onCall;

  void _handleMessageTap(BuildContext context) {
    if (onSelectSms != null || onSelectWhatsApp != null) {
      _showMessageChoiceSheet(context);
    } else {
      onSendMessage?.call();
    }
  }

  void _showMessageChoiceSheet(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Spacing.radiusLg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  locale.driverDetailsChooseMessagingApp,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.md),
                if (onSelectSms != null)
                  ListTile(
                    leading: Icon(Icons.sms_outlined, color: color.primary),
                    title: Text(
                      locale.driverDetailsSms,
                      style: getMediumStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size14,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      onSelectSms?.call();
                    },
                  ),
                if (onSelectWhatsApp != null)
                  ListTile(
                    leading: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: color.tertiary,
                    ),
                    title: Text(
                      locale.driverDetailsWhatsApp,
                      style: getMediumStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size14,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      onSelectWhatsApp?.call();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final hasMessageAction =
        onSelectSms != null || onSelectWhatsApp != null || onSendMessage != null;

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
              onPressed: hasMessageAction ? () => _handleMessageTap(context) : null,
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
                colorFilter: ColorFilter.mode(color.onPrimary, BlendMode.srcIn),
              ),
              iconGap: Spacing.xs,
              textStyle: getSemiBoldStyle(
                color: color.onPrimary,
                fontSize: FontSize.size12,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
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
                colorFilter: ColorFilter.mode(color.primary, BlendMode.srcIn),
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

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';

class AccountStatusHelpCard extends StatelessWidget {
  const AccountStatusHelpCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.accountStatusHelpBorder),
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
      ),
      child: SizedBox(
        height: Spacing.accountStatusHelpCardHeight,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      locale.accountStatusNeedHelp,
                      style: getSemiBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size10,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      locale.accountStatusHelpSubtitle,
                      style: getRegularStyle(
                        color: color.accountStatusMutedText,
                        fontSize: FontSize.size10,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppButton(
                        text: locale.accountStatusGetHelp,
                        onPressed: onPressed,
                        variant: AppButtonVariant.outlined,
                        isExpanded: false,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconSize: Spacing.iconSm,
                        iconGap: Spacing.xs,
                        height: Spacing.accountStatusHelpButtonHeight,
                        borderRadius: Spacing.radiusPill,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.base,
                        ),
                        color: color.primary,
                        textColor: color.primary,
                        textStyle: getSemiBoldStyle(
                          color: color.primary,
                          fontSize: FontSize.size8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              SizedBox.square(
                dimension: Spacing.accountStatusHelpIconSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.primary,
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.headset_mic_rounded,
                    color: color.onPrimary,
                    size: Spacing.iconMd,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

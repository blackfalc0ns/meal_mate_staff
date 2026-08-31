import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/account_status_data.dart';
import 'account_status_illustration.dart';

class AccountUnderReviewCard extends StatelessWidget {
  const AccountUnderReviewCard({super.key, required this.data});

  final AccountStatusData data;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.accountStatusReviewSurface,
        border: Border.all(color: color.accountStatusReviewBorder),
        borderRadius: BorderRadius.circular(
          Spacing.accountStatusUnderReviewCardRadius,
        ),
      ),
      child: SizedBox(
        height: Spacing.accountStatusUnderReviewCardHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Column(
            children: [
              const SizedBox(height: Spacing.xs),
              AccountStatusIllustration(
                asset: data.illustrationAsset,
                width: Spacing.accountStatusUnderReviewImageWidth,
                height: Spacing.accountStatusUnderReviewImageHeight,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
                  child: Text(
                    locale.accountStatusPendingChip,
                    style: getSemiBoldStyle(
                      color: color.onPrimary,
                      fontSize: FontSize.size8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                data.title,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                data.body,
                style: getMediumStyle(
                  color: color.accountStatusMutedText,
                  fontSize: FontSize.size10,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: color.primary,
                    size: Spacing.iconMd,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Flexible(
                    child: Text(
                      locale.accountStatusNotifyWhenApproved,
                      style: getMediumStyle(
                        color: color.accountStatusMutedText,
                        fontSize: FontSize.size10,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

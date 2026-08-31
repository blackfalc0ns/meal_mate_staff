import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/account_status_data.dart';
import '../../domain/account_status_kind.dart';
import 'account_status_header.dart';
import 'account_status_help_card.dart';
import 'account_status_result_content.dart';
import 'account_status_trust_note.dart';
import 'account_under_review_card.dart';

class AccountStatusContent extends StatelessWidget {
  const AccountStatusContent({
    super.key,
    required this.kind,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.onHelpPressed,
  });

  final AccountStatusKind kind;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onHelpPressed;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;
    final data = AccountStatusData.fromKind(
      kind,
      locale,
      acceptedAsset: AppAssets.accountStatusAccepted,
      rejectedAsset: AppAssets.accountStatusRejected,
      moreInfoAsset: AppAssets.accountStatusMoreInfo,
      underReviewAsset: AppAssets.accountStatusUnderReview,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: kind == AccountStatusKind.underReview
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.accountStatusLogoTop),
                AccountStatusHeader(
                  title: locale.accountStatusTitle,
                  subtitle: locale.accountStatusSubtitle,
                ),
                const SizedBox(height: Spacing.lg),
                AccountUnderReviewCard(data: data),
                const SizedBox(height: Spacing.lg),
                AccountStatusHelpCard(onPressed: onHelpPressed ?? () {}),
                const SizedBox(height: Spacing.lg),
                const AccountStatusTrustNote(),
                const SizedBox(height: Spacing.screenV),
              ],
            )
          : AccountStatusResultContent(
              data: data,
              onPrimaryPressed: onPrimaryPressed ?? () {},
              onSecondaryPressed: onSecondaryPressed ?? () {},
            ),
    );
  }
}

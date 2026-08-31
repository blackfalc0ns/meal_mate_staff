import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/widgets/auth_header_logo.dart';
import '../../domain/account_status_data.dart';
import '../widgets/account_status_action_buttons.dart';
import '../widgets/account_status_illustration.dart';
import '../widgets/account_status_reason_panel.dart';

class AccountStatusResultContent extends StatelessWidget {
  const AccountStatusResultContent({
    super.key,
    required this.data,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final AccountStatusData data;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.accountStatusLogoTop),
        const AuthHeaderLogo.compact(),
        const SizedBox(height: Spacing.accountStatusResultImageTop),
        AccountStatusIllustration(asset: data.illustrationAsset),
        SizedBox(
          height: data.hasReasons
              ? Spacing.accountStatusContentTop
              : Spacing.accountStatusAcceptedContentTop,
        ),
        Text(
          data.title,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.base),
        Text(
          data.body,
          style: getRegularStyle(
            color: color.accountStatusBodyText,
            fontSize: FontSize.size14,
            height: 1.84,
          ),
          textAlign: TextAlign.center,
        ),
        if (data.hasReasons) ...[
          const SizedBox(height: Spacing.accountStatusReasonTop),
          AccountStatusReasonPanel(
            title: data.reasonTitle!,
            reasons: data.reasons,
            tone: data.reasonTone!,
          ),
        ],
        const SizedBox(height: Spacing.accountStatusButtonTop),
        AccountStatusActionButtons(
          primaryText: data.primaryAction!,
          secondaryText: data.secondaryAction!,
          onPrimaryPressed: onPrimaryPressed,
          onSecondaryPressed: onSecondaryPressed,
        ),
        const SizedBox(height: Spacing.screenV),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/account_status_reason_tone.dart';

class AccountStatusReasonPanel extends StatelessWidget {
  const AccountStatusReasonPanel({
    super.key,
    required this.title,
    required this.reasons,
    required this.tone,
  });

  final String title;
  final List<String> reasons;
  final AccountStatusReasonTone tone;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final panelColor = switch (tone) {
      AccountStatusReasonTone.warning => color.accountStatusWarningSurface,
      AccountStatusReasonTone.error => color.accountStatusErrorSurface,
    };
    final bulletColor = switch (tone) {
      AccountStatusReasonTone.warning => color.accountStatusWarning,
      AccountStatusReasonTone.error => color.accountStatusError,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(
          Spacing.accountStatusReasonPanelRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: Spacing.accountStatusReasonPanelPaddingHorizontal,
          top: Spacing.accountStatusReasonPanelPaddingTop,
          end: Spacing.accountStatusReasonPanelPaddingHorizontal,
          bottom: Spacing.base,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: getBoldStyle(
                color: color.onSurface,
                fontSize: FontSize.size14,
              ),
             
            ),
            const SizedBox(height: Spacing.lg),
            for (final reason in reasons) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: Spacing.accountStatusReasonBullet,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: bulletColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Text(
                      reason,
                      style: getRegularStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size13,
                        height: 1.84,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              if (reason != reasons.last) const SizedBox(height: Spacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

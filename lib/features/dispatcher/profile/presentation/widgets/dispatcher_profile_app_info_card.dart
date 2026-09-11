import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherProfileAppInfoCard extends StatelessWidget {
  const DispatcherProfileAppInfoCard({
    super.key,
    required this.appVersion,
    this.onTermsTap,
    this.onPrivacyPolicyTap,
  });

  final String appVersion;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyPolicyTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.profileAppInfo,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_unread_rounded,
                  size: Spacing.iconXs,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.profileAppVersion,
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  appVersion,
                  style: getSemiBoldStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: Spacing.iconSm,
                  color: color.onSurfaceVariant,
                ),
              ],
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.3),
          ),
          InkWell(
            onTap: onTermsTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.article_rounded,
                    size: Spacing.iconXs,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.profileTermsConditions,
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.3),
          ),
          InkWell(
            onTap: onPrivacyPolicyTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: Spacing.iconXs,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.profilePrivacyPolicy,
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

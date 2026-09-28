import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverIssuesHelpBanner extends StatelessWidget {
  const DriverIssuesHelpBanner({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Material(
      color: color.driverWarningBannerBg,
      borderRadius: BorderRadius.circular(Spacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(
              color: color.driverWarningBannerBorder.withValues(alpha: 0.3),
              width: Spacing.hairline,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: color.accountStatusWarning,
                size: _iconSize,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.driverIssuesWarningTitle,
                      style: getBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.accountStatusWarning,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      locale.driverIssuesWarningSubtitle,
                      style: getRegularStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

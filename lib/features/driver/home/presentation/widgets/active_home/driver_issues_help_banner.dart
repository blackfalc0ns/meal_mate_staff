import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverIssuesHelpBanner extends StatelessWidget {
  const DriverIssuesHelpBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  static const double _iconSize = 34;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Material(
      color: const Color(0xFFFFF4EC),
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
              color: const Color(0xFFFFE0CC),
              width: Spacing.hairline,
            ),
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.driverIssuesWarningTitle,
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: const Color(0xFFE2613B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locale.driverIssuesWarningSubtitle,
                      style: getRegularStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFE2613B),
                size: _iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

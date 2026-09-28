import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverStartWorkStatusCard extends StatelessWidget {
  const DriverStartWorkStatusCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  static const double _cardRadius = 24.0;
  static const double _innerRadius = 16.0;
  static const double _dotSize = 8.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E0FA),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.driverStartWorkIllustration,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.xs,
                  Spacing.md,
                  Spacing.md,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: Spacing.md,
                    horizontal: Spacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(_innerRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locale.driverStatusNow,
                        style: getBoldStyle(
                          fontSize: FontSize.size14,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: _dotSize,
                            height: _dotSize,
                            decoration: BoxDecoration(
                              color: color.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            locale.driverStatusOffline,
                            style: getBoldStyle(
                              fontSize: FontSize.size18,
                              color: color.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.driverNotAvailableDescription,
                        style: getRegularStyle(
                          fontSize: FontSize.size12,
                          color: color.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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

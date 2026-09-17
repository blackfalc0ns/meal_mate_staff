import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverProfileSupportCard extends StatelessWidget {
  const DriverProfileSupportCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  static const double _iconBoxSize = 40;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Material(
      color: color.surface,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(
              color: color.outline,
              width: Spacing.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: _iconBoxSize,
                height: _iconBoxSize,
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: color.primary,
                  size: Spacing.iconMd,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverContactSupportTitle,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size13,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      locale.driverContactSupportDesc,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: Spacing.iconXs,
                color: color.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverProfileRecentTicketCard extends StatelessWidget {
  const DriverProfileRecentTicketCard({
    super.key,
    required this.profile,
    this.onViewAllTap,
  });

  final DriverProfileEntity profile;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outline,
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  locale.driverRecentTicketTitle,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  locale.driverViewAll,
                  style: getMediumStyle(
                    color: color.primary,
                    fontSize: FontSize.size11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.recentTicketId,
                            style: getBoldStyle(
                              color: color.primary,
                              fontSize: FontSize.size12,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Text(
                            profile.recentTicketDate,
                            style: getRegularStyle(
                              color: color.onSurfaceVariant,
                              fontSize: FontSize.size10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        profile.recentTicketSubject,
                        style: getRegularStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (profile.isTicketResolved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.tertiaryContainer,
                      borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    ),
                    child: Text(
                      locale.driverTicketStatusResolved,
                      style: getMediumStyle(
                        color: color.tertiary,
                        fontSize: FontSize.size10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

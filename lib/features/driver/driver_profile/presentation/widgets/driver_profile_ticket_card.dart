import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverProfileTicketCard extends StatelessWidget {
  const DriverProfileTicketCard({
    super.key,
    required this.profile,
    this.onTap,
    this.onViewAllTap,
  });

  final DriverProfileEntity profile;
  final VoidCallback? onTap;
  final VoidCallback? onViewAllTap;

  static const double _iconBoxSize = 40.0;
  static const double _statusDotSize = 6.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                locale.driverRecentTicketTitle,
                style: getBoldStyle(
                  fontSize: FontSize.size14,
                  color: color.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            InkWell(
              onTap: onViewAllTap,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Text(
                  locale.driverViewAll,
                  style: getMediumStyle(
                    fontSize: FontSize.size11,
                    color: color.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(
                color: color.outlineVariant,
                width: Spacing.border,
              ),
            ),
            padding: const EdgeInsets.all(Spacing.cardPadding),
            child: Row(
              children: [
                Container(
                  width: _iconBoxSize,
                  height: _iconBoxSize,
                  decoration: BoxDecoration(
                    color: color.primary,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: Spacing.iconMd,
                    color: color.onPrimary,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.recentTicketId,
                        style: getBoldStyle(
                          fontSize: FontSize.size12,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.recentTicketSubject,
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: _statusDotSize,
                            height: _statusDotSize,
                            decoration: BoxDecoration(
                              color: color.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            locale.driverTicketStatusResolved,
                            style: getMediumStyle(
                              fontSize: FontSize.size11,
                              color: color.tertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locale.driverTicketResolvedSubtitle,
                        style: getRegularStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        profile.recentTicketDate,
                        style: getBoldStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locale.driverTicketDateLabel,
                        style: getRegularStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Icon(
                  Icons.chevron_left_rounded,
                  size: Spacing.iconSm,
                  color: color.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

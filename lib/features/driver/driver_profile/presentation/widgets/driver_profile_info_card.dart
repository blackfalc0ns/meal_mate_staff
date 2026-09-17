import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';
import 'driver_profile_kpi_item.dart';

class DriverProfileInfoCard extends StatelessWidget {
  const DriverProfileInfoCard({
    super.key,
    required this.profile,
  });

  final DriverProfileEntity profile;

  static const double _avatarSize = 48;
  static const double _onlineDotSize = 8;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.inverseSurface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: _avatarSize,
                    height: _avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.primaryContainer,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: Spacing.iconLg,
                      color: color.primary,
                    ),
                  ),
                  if (profile.isOnline)
                    PositionedDirectional(
                      end: 0,
                      bottom: 0,
                      child: Container(
                        width: _onlineDotSize,
                        height: _onlineDotSize,
                        decoration: BoxDecoration(
                          color: color.tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.inverseSurface,
                            width: Spacing.border,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: getBoldStyle(
                        color: color.onInverseSurface,
                        fontSize: FontSize.size16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Text(
                          '${locale.driverIdLabel} ${profile.driverId}',
                          style: getRegularStyle(
                            color: color.onInverseSurface.withValues(alpha: 0.7),
                            fontSize: FontSize.size11,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs,
                            vertical: Spacing.xs / 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.tertiary.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(Spacing.radiusPill),
                          ),
                          child: Text(
                            locale.driverStatusOnline,
                            style: getMediumStyle(
                              color: color.tertiary,
                              fontSize: FontSize.size10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.onInverseSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: Spacing.iconXs,
                      color: color.secondary,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Text(
                      '${profile.rating}',
                      style: getBoldStyle(
                        color: color.onInverseSurface,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),
          Row(
            children: [
              Expanded(
                child: DriverProfileKpiItem(
                  label: locale.driverTotalOrders,
                  value: '${profile.totalOrders}',
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: DriverProfileKpiItem(
                  label: locale.driverAcceptanceRate,
                  value: '${profile.acceptanceRate}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: DriverProfileKpiItem(
                  label: locale.driverRating,
                  value: '★ ${profile.rating}',
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: DriverProfileKpiItem(
                  label: locale.driverMemberSince,
                  value: profile.memberSince,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

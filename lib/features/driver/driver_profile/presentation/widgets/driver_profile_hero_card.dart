import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverProfileHeroCard extends StatelessWidget {
  const DriverProfileHeroCard({
    super.key,
    required this.profile,
  });

  final DriverProfileEntity profile;

  static const double _avatarSize = 52.0;
  static const double _onlineDotSize = 11.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.inverseSurface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Container(
                    width: _avatarSize,
                    height: _avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.outline.withValues(alpha: 0.3),
                        width: Spacing.border,
                      ),
                      image: DecorationImage(
                        image: AssetImage(profile.avatarAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (profile.isOnline)
                    Container(
                      width: _onlineDotSize,
                      height: _onlineDotSize,
                      decoration: BoxDecoration(
                        color: color.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.inverseSurface,
                          width: 1.5,
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
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: getBoldStyle(
                            fontSize: FontSize.size15,
                            color: color.onInverseSurface,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: color.onInverseSurface.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.onInverseSurface.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            locale.driverIdLabel,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onInverseSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            profile.driverId,
                            style: getMediumStyle(
                              fontSize: FontSize.size11,
                              color: color.onInverseSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: color.secondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          profile.rating.toString(),
                          style: getBoldStyle(
                            fontSize: FontSize.size12,
                            color: color.onInverseSurface,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          '(${profile.reviewsCount} ${locale.driverRatingReviews})',
                          style: getRegularStyle(
                            fontSize: FontSize.size11,
                            color: color.onInverseSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Divider(
            color: color.onInverseSurface.withValues(alpha: 0.15),
            height: Spacing.md,
            thickness: Spacing.border,
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locale.driverTotalOrders,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onInverseSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.totalOrders}',
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onInverseSurface,
                      ),
                    ),
                    Text(
                      locale.driverOrdersUnit,
                      style: getRegularStyle(
                        fontSize: FontSize.size9,
                        color: color.onInverseSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locale.driverAcceptanceRate,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onInverseSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.acceptanceRate}%',
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onInverseSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locale.driverRating,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onInverseSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${profile.rating}',
                          style: getBoldStyle(
                            fontSize: FontSize.size13,
                            color: color.onInverseSurface,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: color.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locale.driverMemberSince,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onInverseSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.memberSince,
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onInverseSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



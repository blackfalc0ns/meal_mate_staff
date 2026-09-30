import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../../../../core/widget/shimmer_widget.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverProfileHeroCard extends StatelessWidget {
  const DriverProfileHeroCard({
    super.key,
    required this.profile,
    this.onAvatarResolved,
  });

  final DriverProfileEntity profile;
  final ValueChanged<bool>? onAvatarResolved;

  static const double _avatarSize = 52.0;
  static const double _onlineDotSize = 11.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final ratingText = profile.averageRating != null
        ? profile.averageRating!.toStringAsFixed(1)
        : null;
    final acceptanceText = profile.acceptanceRatePercent != null
        ? '${profile.acceptanceRatePercent!.toStringAsFixed(0)}%'
        : null;
    final joinedText = profile.joinedAtUtc != null
        ? '${profile.joinedAtUtc!.year}-${profile.joinedAtUtc!.month.toString().padLeft(2, '0')}'
        : null;

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
                  AppCachedNetworkImage(
                    imageUrl: profile.profileImageUrl,
                    width: _avatarSize,
                    height: _avatarSize,
                    shape: BoxShape.circle,
                    onImageResolved: onAvatarResolved,
                    loadingWidget: const ShimmerWidget(
                      width: _avatarSize,
                      height: _avatarSize,
                      borderRadius: _avatarSize / 2,
                    ),
                    errorWidget: Container(
                      width: _avatarSize,
                      height: _avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.onInverseSurface.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: color.onInverseSurface.withValues(alpha: 0.7),
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
                        Flexible(
                          child: Text(
                            profile.fullName,
                            style: getBoldStyle(
                              fontSize: FontSize.size15,
                              color: color.onInverseSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.driverRank != null &&
                            profile.driverRank!.isNotEmpty) ...[
                          const SizedBox(width: Spacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: color.secondary.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusPill),
                            ),
                            child: Text(
                              profile.driverRank!,
                              style: getMediumStyle(
                                fontSize: FontSize.size9,
                                color: color.secondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (profile.driverDescription.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.driverDescription,
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.onInverseSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                color.onInverseSurface.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(Spacing.radiusPill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                locale.driverIdLabel,
                                style: getRegularStyle(
                                  fontSize: FontSize.size10,
                                  color: color.onInverseSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(width: Spacing.xs),
                              Text(
                                profile.driverCode,
                                style: getMediumStyle(
                                  fontSize: FontSize.size11,
                                  color: color.onInverseSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (profile.statusText.isNotEmpty) ...[
                          const SizedBox(width: Spacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: profile.isOnline
                                  ? color.tertiary.withValues(alpha: 0.2)
                                  : color.onInverseSurface
                                      .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusPill),
                            ),
                            child: Text(
                              profile.statusText,
                              style: getMediumStyle(
                                fontSize: FontSize.size10,
                                color: profile.isOnline
                                  ? color.tertiary
                                  : color.onInverseSurface
                                      .withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (ratingText != null) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: color.secondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            ratingText,
                            style: getBoldStyle(
                              fontSize: FontSize.size12,
                              color: color.onInverseSurface,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                        ],
                        Text(
                          '(${profile.reviewsCount} ${locale.driverRatingReviews})',
                          style: getRegularStyle(
                            fontSize: FontSize.size11,
                            color:
                                color.onInverseSurface.withValues(alpha: 0.7),
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
                      acceptanceText ?? locale.driverProfileUnavailable,
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
                    Text(
                      ratingText != null ? '$ratingText ★' : locale.driverProfileUnavailable,
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
                      joinedText ?? locale.driverProfileUnavailable,
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onInverseSurface,
                      ),
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

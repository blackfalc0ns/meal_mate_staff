import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverSettingsProfileCard extends StatelessWidget {
  const DriverSettingsProfileCard({
    super.key,
    required this.profile,
    this.onEditProfileTap,
  });

  final DriverProfileEntity profile;
  final VoidCallback? onEditProfileTap;

  static const double _avatarSize = 64;
  static const double _statusDotSize = 12;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline, width: Spacing.border),
      ),
      child: Row(
        children: [
          // Driver Avatar (Start side: right in RTL, left in LTR)
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
                child: ClipOval(
                  child: Image.asset(
                    profile.avatarAsset,
                    width: _avatarSize,
                    height: _avatarSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.person_rounded,
                      size: Spacing.iconLg,
                      color: color.primary,
                    ),
                  ),
                ),
              ),
              if (profile.isOnline)
                PositionedDirectional(
                  end: 0,
                  bottom: 2,
                  child: Container(
                    width: _statusDotSize,
                    height: _statusDotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.tertiary,
                      border: Border.all(color: color.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: Spacing.md),
          // Profile Info: Name, ID, Online Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.name,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.primaryContainer,
                      borderRadius: BorderRadius.circular(Spacing.radiusLg),
                    ),
                    child: Text(
                      profile.driverId,
                      style: getBoldStyle(
                        color: color.primary,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                if (profile.isOnline)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.tertiary,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        locale.driverStatusOnline,
                        style: getMediumStyle(
                          color: color.tertiary,
                          fontSize: FontSize.size11,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Edit Profile button on the End side (left in RTL, right in LTR)
          InkWell(
            onTap: onEditProfileTap,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locale.driverSettingsEditProfile,
                    style: getMediumStyle(
                      color: color.primary,
                      fontSize: FontSize.size10,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.edit_outlined,
                    size: Spacing.iconSm,
                    color: color.primary,
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

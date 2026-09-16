import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_profile_entity.dart';

class DispatcherProfileAdminCard extends StatelessWidget {
  const DispatcherProfileAdminCard({
    super.key,
    required this.profile,
    this.onChangePhotoTap,
    this.onPhoneTap,
    this.onEmailTap,
    this.onPasswordTap,
  });

  final DispatcherProfileEntity profile;
  final VoidCallback? onChangePhotoTap;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onEmailTap;
  final VoidCallback? onPasswordTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.profileAdminInfo,
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            profile.avatarAsset,
                            width: Spacing.dispatcherDriverAvatarSize * 1.8,
                            height: Spacing.dispatcherDriverAvatarSize * 1.8,
                            fit: BoxFit.cover,
                          ),
                        ),
                        PositionedDirectional(
                          bottom: 0,
                          end: 0,
                          child: InkWell(
                            onTap: onChangePhotoTap,
                            borderRadius: BorderRadius.circular(
                              Spacing.radiusPill,
                            ),
                            child: Container(
                              width: Spacing.iconLg * 0.85,
                              height: Spacing.iconLg * 0.85,
                              decoration: BoxDecoration(
                                color: color.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color.outlineVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                  width: Spacing.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: Spacing.iconXs,
                                color: color.primary,
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
                              fontSize: FontSize.size15,
                              color: color.onSurface,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Wrap(
                            spacing: Spacing.xs,
                            runSpacing: Spacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.sm,
                                  vertical: Spacing.xs / 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    Spacing.radiusXs,
                                  ),
                                ),
                                child: Text(
                                  profile.roleCode,
                                  style: getSemiBoldStyle(
                                    fontSize: FontSize.size11,
                                    color: color.primary,
                                  ),
                                ),
                              ),
                              if (profile.isAvailable)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Spacing.sm,
                                    vertical: Spacing.xs / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.secondaryContainer.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Spacing.radiusXs,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: Spacing.xs * 1.5,
                                        height: Spacing.xs * 1.5,
                                        decoration: BoxDecoration(
                                          color: color.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: Spacing.xs),
                                      Text(
                                        locale.profileAvailableNow,
                                        style: getMediumStyle(
                                          fontSize: FontSize.size10,
                                          color: color.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            profile.roleTitle,
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
              ],
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.4),
          ),
          InkWell(
            onTap: onPhoneTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_rounded,
                    size: Spacing.iconXs,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.profilePhoneNumber,
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      profile.phone,
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.ltr,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.4),
          ),
          InkWell(
            onTap: onEmailTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mail_rounded,
                    size: Spacing.iconXs,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.profileEmail,
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          profile.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: getSemiBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onSurface,
                          ),
                        ),
                        if (!profile.isEmailEditable)
                          Text(
                            '( ${locale.profileNonEditable} )',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getRegularStyle(
                              fontSize: FontSize.size9,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.4),
          ),
          InkWell(
            onTap: onPasswordTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: Spacing.iconXs,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.profilePassword,
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      profile.maskedPassword,
                      textAlign: TextAlign.end,
                      style: getBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: Spacing.iconSm,
                    color: color.onSurfaceVariant,
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

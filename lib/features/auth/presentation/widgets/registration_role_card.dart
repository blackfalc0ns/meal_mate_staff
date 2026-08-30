import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class RegistrationRoleCard extends StatelessWidget {
  const RegistrationRoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.isSelected,
    required this.onTap,
    this.badgeText,
    this.unselectedBorderColor,
    this.unselectedIndicatorColor,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? unselectedBorderColor;
  final Color? unselectedIndicatorColor;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: color.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        side: BorderSide(
          color: isSelected
              ? color.primary
              : (unselectedBorderColor ?? color.outline),
          width: isSelected
              ? (Spacing.border + Spacing.hairline)
              : Spacing.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.cardPadding,
            vertical: Spacing.md,
          ),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: color.primaryContainer,
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: Spacing.iconSm - Spacing.xs,
                            color: color.primary,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            badgeText!,
                            style: getMediumStyle(
                              color: color.primary,
                              fontSize: FontSize.size10,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: Spacing.lg),
                  const SizedBox(height: Spacing.md),
                  Icon(
                    isRtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: Spacing.iconMd,
                    color: isSelected
                        ? color.primary
                        : (unselectedIndicatorColor ?? color.error),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size16,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      subtitle,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.cardPadding),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: Spacing.bottomNavHeight,
                    height: Spacing.bottomNavHeight,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.primaryContainer,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        imageAsset,
                        width: Spacing.bottomNavHeight,
                        height: Spacing.bottomNavHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: Spacing.zero,
                    end: Spacing.zero,
                    child: Container(
                      width: Spacing.iconMd,
                      height: Spacing.iconMd,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? color.primary : color.surface,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: unselectedIndicatorColor ?? color.error,
                                width: Spacing.border * 2,
                              ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: Spacing.iconSm,
                              color: color.onPrimary,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

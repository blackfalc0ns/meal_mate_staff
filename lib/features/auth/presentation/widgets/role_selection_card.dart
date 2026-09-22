import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/staff_role_entity.dart';

class RoleSelectionCard extends StatelessWidget {
  const RoleSelectionCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final StaffRoleEntity role;
  final bool isSelected;
  final VoidCallback onTap;

  String get _imageAsset {
    final key = role.iconKey.toLowerCase();
    if (key.contains('driver')) {
      return AppAssets.registrationDriverRole;
    }
    return AppAssets.registrationOpsRole;
  }

  IconData get _fallbackIcon {
    final key = role.iconKey.toLowerCase();
    if (key.contains('driver')) {
      return Icons.two_wheeler_rounded;
    }
    return Icons.dashboard_customize_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    final title = role.localizedName(isArabic);
    final description = role.localizedDescription(isArabic);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusXl),
        border: Border.all(
          color: isSelected
              ? color.primary
              : color.outlineVariant.withValues(alpha: 0.8),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.primary.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: color.shadow.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.radiusXl),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.base),
            child: Row(
              children: [
                // Role Avatar / Image
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? color.primary.withValues(alpha: 0.1)
                            : color.surfaceContainerHighest.withValues(
                                alpha: 0.4,
                              ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          _imageAsset,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            _fallbackIcon,
                            size: 28,
                            color: isSelected
                                ? color.primary
                                : color.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: color.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: color.surface, width: 2),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: color.onPrimary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Spacing.md),
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: getBoldStyle(
                                color: isSelected
                                    ? color.primary
                                    : color.onSurface,
                                fontSize: FontSize.size16,
                              ),
                            ),
                          ),
                          if (role.allowsSelfRegistration)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.xs + 2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(
                                  Spacing.radiusSm,
                                ),
                              ),
                              child: Text(
                                isArabic ? 'تسجيل ذاتي' : 'Self sign-up',
                                style: getMediumStyle(
                                  color: color.primary,
                                  fontSize: FontSize.size10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        description,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? color.primary : color.outlineVariant,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

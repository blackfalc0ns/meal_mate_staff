import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/user_role.dart';
import 'registration_role_card.dart';

class AccountTypeBottomSheet extends StatelessWidget {
  const AccountTypeBottomSheet({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onConfirm,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.16),
            blurRadius: Spacing.screenH,
            offset: const Offset(Spacing.zero, -Spacing.xs),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.base,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: Spacing.xxxl - Spacing.xs,
              height: Spacing.xs,
              decoration: BoxDecoration(
                color: color.outlineVariant,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            locale.registrationChooseAccountType,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size18,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.registrationChooseRoleSubtitle,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size11,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.base),
          RegistrationRoleCard(
            title: locale.registrationDriverRole,
            subtitle: locale.registrationDriverRoleSubtitle,
            imageAsset: AppAssets.registrationDriverRole,
            badgeText: locale.registrationDefaultRole,
            isSelected: selectedRole == UserRole.driver,
            onTap: () => onRoleChanged(UserRole.driver),
          ),
          const SizedBox(height: Spacing.md),
          RegistrationRoleCard(
            title: locale.registrationOpsRole,
            subtitle: locale.registrationOpsRoleSubtitle,
            imageAsset: AppAssets.registrationOpsRole,
            unselectedBorderColor: color.errorContainer,
            unselectedIndicatorColor: color.error,
            isSelected: selectedRole == UserRole.operations,
            onTap: () => onRoleChanged(UserRole.operations),
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            height: Spacing.buttonHeight,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.primary,
                foregroundColor: color.onPrimary,
                elevation: Spacing.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.buttonRadius),
                ),
              ),
              child: Text(
                locale.registrationConfirm,
                style: getBoldStyle(
                  color: color.onPrimary,
                  fontSize: FontSize.size16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

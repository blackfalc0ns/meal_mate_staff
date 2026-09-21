import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/network/failures.dart';
import '../../domain/entities/staff_role_entity.dart';
import '../../domain/user_role.dart';
import 'registration_role_card.dart';

class AccountTypeBottomSheet extends StatelessWidget {
  const AccountTypeBottomSheet({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onConfirm,
    this.roles = const [],
    this.isLoading = false,
    this.isNavigating = false,
    this.failure,
    this.onRetry,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onConfirm;
  final List<StaffRoleEntity> roles;
  final bool isLoading;
  final bool isNavigating;
  final Failure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

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

          // Dynamic Content States
          if (isLoading && roles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (failure != null && roles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              child: InlineApiErrorWidget(
                failure: failure!,
                onRetry: onRetry,
              ),
            )
          else if (roles.isNotEmpty)
            ...roles.asMap().entries.map((entry) {
              final index = entry.key;
              final role = entry.value;
              final isDriver = role.iconKey.toLowerCase().contains('driver') ||
                  role.code.toLowerCase() == 'driver';
              final isSelected = selectedRole == role.userRole;
              final badge = isDriver
                  ? locale.registrationDefaultRole
                  : (role.allowsSelfRegistration
                      ? (isArabic ? 'تسجيل ذاتي' : 'Self-Registration')
                      : null);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < roles.length - 1 ? Spacing.md : Spacing.zero,
                ),
                child: RegistrationRoleCard(
                  title: role.localizedName(isArabic),
                  subtitle: role.localizedDescription(isArabic),
                  imageAsset: isDriver
                      ? AppAssets.registrationDriverRole
                      : AppAssets.registrationOpsRole,
                  badgeText: badge,
                  unselectedBorderColor: isDriver ? null : color.errorContainer,
                  unselectedIndicatorColor: isDriver ? null : color.error,
                  isSelected: isSelected,
                  onTap: () => onRoleChanged(role.userRole),
                ),
              );
            })
          else ...[
            // Default static fallback when roles are empty
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
          ],

          const SizedBox(height: Spacing.lg),
          SizedBox(
            height: Spacing.buttonHeight,
            child: ElevatedButton(
              onPressed: isNavigating ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.primary,
                foregroundColor: color.onPrimary,
                elevation: Spacing.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.buttonRadius),
                ),
              ),
              child: isNavigating
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: color.onPrimary,
                      ),
                    )
                  : Text(
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

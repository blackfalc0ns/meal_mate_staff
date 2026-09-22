import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/di/di.dart';
import '../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/services/app_locale_notifier.dart';
import '../../../../core/widget/app_button.dart';
import '../../domain/entities/staff_role_entity.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';
import '../manager/auth_view_model.dart';
import '../widgets/role_selection_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, this.viewModel});

  final AuthViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final vm =
        viewModel ??
        (getIt.isRegistered<AuthViewModel>() ? getIt<AuthViewModel>() : null);
    if (vm != null) {
      return BlocProvider.value(value: vm, child: const _RoleSelectionView());
    }
    return const _RoleSelectionView();
  }
}

class _RoleSelectionView extends StatefulWidget {
  const _RoleSelectionView();

  @override
  State<_RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<_RoleSelectionView> {
  StaffRoleEntity? _selectedRole;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.state.roles.isEmpty &&
        !authViewModel.state.isLoadingRoles) {
      authViewModel.doIntent(const AuthGetStaffRolesEvent());
    } else if (authViewModel.state.roles.isNotEmpty) {
      _selectedRole = authViewModel.state.roles.first;
    }
  }

  void _onContinue() {
    if (_selectedRole == null) return;
    final userRole = _selectedRole!.userRole;
    context.read<AuthViewModel>().doIntent(AuthRoleChangedEvent(userRole));
    context.pushNamed(
      AppRoutes.login,
      arguments: LoginRouteArgs(role: userRole),
    );
  }

  void _toggleLanguage() {
    final currentLocale = appLocaleNotifier.value;
    final nextLocale = currentLocale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    appLocaleNotifier.value = nextLocale;
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: BlocConsumer<AuthViewModel, AuthState>(
          listenWhen: (previous, current) =>
              previous.roles != current.roles && current.roles.isNotEmpty,
          listener: (context, state) {
            if (_selectedRole == null && state.roles.isNotEmpty) {
              setState(() {
                _selectedRole = state.roles.first;
              });
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Top Action Bar with Language Switcher
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.screenH,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo mark
                      Image.asset(
                        AppAssets.authHeaderLogo,
                        height: 28,
                        errorBuilder: (_, _, _) => const SizedBox(width: 28),
                      ),
                      // Language Toggle Chip
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggleLanguage,
                          borderRadius: BorderRadius.circular(
                            Spacing.radiusPill,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: color.surfaceContainerHighest.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                Spacing.radiusPill,
                              ),
                              border: Border.all(
                                color: color.outlineVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language_rounded,
                                  size: Spacing.iconSm,
                                  color: color.primary,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  isArabic ? 'English' : 'العربية',
                                  style: getSemiBoldStyle(
                                    color: color.onSurface,
                                    fontSize: FontSize.size12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(child: _buildBody(context, state, locale, color)),

                // Bottom Continue Button (fixed)
                if (state.roles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.screenH,
                      vertical: Spacing.md,
                    ),
                    child: AppButton(
                      text: locale.commonContinue,
                      onPressed: _selectedRole != null ? _onContinue : null,
                      height: Spacing.buttonHeight,
                      borderRadius: Spacing.buttonRadius,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthState state,
    dynamic locale,
    ColorScheme color,
  ) {
    if (state.isLoadingRoles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.rolesFailure != null && state.roles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.base),
          child: ApiErrorWidget(
            exception: state.rolesFailure!.exception,
            onRetry: () {
              context.read<AuthViewModel>().doIntent(
                const AuthGetStaffRolesEvent(),
              );
            },
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xl),
          // Large Center Logo
          Center(
            child: Image.asset(
              AppAssets.authLogo,
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.local_shipping_rounded,
                size: 72,
                color: color.primary,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Titles
          Text(
            locale.authRoleSelectionTitle,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size22,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.authRoleSelectionSubtitle,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size13,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xxl),

          // Roles List
          ...state.roles.map((role) {
            final isSelected = _selectedRole?.code == role.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: RoleSelectionCard(
                role: role,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedRole = role;
                  });
                },
              ),
            );
          }),

          const SizedBox(height: Spacing.base),
        ],
      ),
    );
  }
}

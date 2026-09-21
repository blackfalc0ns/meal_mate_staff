import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/di/di.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/network/api_results.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/services/token_service.dart';
import '../../../account_status/domain/account_status_kind.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/staff_role_entity.dart';
import '../../domain/usecase/get_staff_roles_usecase.dart';
import '../../domain/usecase/restore_session_usecase.dart';
import '../../domain/user_role.dart';
import '../widgets/account_type_bottom_sheet.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.initialLoadingDuration = Duration.zero,
    this.restoreSessionUseCase,
    this.tokenService,
    this.getStaffRolesUseCase,
  });

  final Duration initialLoadingDuration;
  final RestoreSessionUseCase? restoreSessionUseCase;
  final TokenService? tokenService;
  final GetStaffRolesUseCase? getStaffRolesUseCase;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late bool _isLoading;
  bool _isNavigating = false;
  UserRole _selectedRole = UserRole.driver;
  List<StaffRoleEntity> _roles = [];
  bool _isLoadingRoles = false;
  Failure? _rolesFailure;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.authLoginBackground), context);
    precacheImage(const AssetImage(AppAssets.authHeaderLogo), context);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _isLoading = true;
    _initializeStartup();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    GetStaffRolesUseCase? rolesUseCase = widget.getStaffRolesUseCase;
    if (rolesUseCase == null && getIt.isRegistered<GetStaffRolesUseCase>()) {
      rolesUseCase = getIt<GetStaffRolesUseCase>();
    }

    if (rolesUseCase == null) return;

    if (mounted) {
      setState(() {
        _isLoadingRoles = true;
        _rolesFailure = null;
      });
    }

    final result = await rolesUseCase();
    if (!mounted) return;

    if (result is ApiSuccessResult<List<StaffRoleEntity>>) {
      setState(() {
        _roles = result.data;
        _isLoadingRoles = false;
        _rolesFailure = null;
        if (_roles.isNotEmpty) {
          final hasCurrent = _roles.any((r) => r.userRole == _selectedRole);
          if (!hasCurrent) {
            _selectedRole = _roles.first.userRole;
          }
        }
      });
    } else if (result is ApiErrorResult<List<StaffRoleEntity>>) {
      setState(() {
        _isLoadingRoles = false;
        _rolesFailure = result.failure;
      });
    }
  }

  Future<void> _initializeStartup() async {
    if (widget.initialLoadingDuration > Duration.zero) {
      await Future.delayed(widget.initialLoadingDuration);
    }
    if (!mounted) return;

    RestoreSessionUseCase? useCase = widget.restoreSessionUseCase;
    if (useCase == null && getIt.isRegistered<RestoreSessionUseCase>()) {
      useCase = getIt<RestoreSessionUseCase>();
    }

    if (useCase != null) {
      final result = await useCase();
      if (!mounted) return;

      if (result is ApiSuccessResult<AuthSessionEntity?> &&
          result.data != null) {
        final session = result.data!;
        if (session.isAuthenticated) {
          final role = session.user.role;
          context.pushReplacementNamed(
            AppRoutes.appShell,
            arguments: AppShellRouteArgs(role: role),
          );
          return;
        }
      }
    }

    TokenService? tokenService = widget.tokenService;
    if (tokenService == null && getIt.isRegistered<TokenService>()) {
      tokenService = getIt<TokenService>();
    }

    if (tokenService != null) {
      final savedStatus = tokenService.getSavedAccountStatus();
      if (savedStatus != null && savedStatus.isNotEmpty) {
        if (!mounted) return;
        context.pushReplacementNamed(
          AppRoutes.accountStatus,
          arguments: const AccountStatusRouteArgs(
            kind: AccountStatusKind.underReview,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  void _navigateToLogin() {
    if (!mounted || _isNavigating) return;
    setState(() {
      _isNavigating = true;
    });
    context.pushReplacementNamed(
      AppRoutes.login,
      arguments: LoginRouteArgs(role: _selectedRole),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Exact Figma Splash background (node 1275-3665)
          Image.asset(AppAssets.authSplashBackground, fit: BoxFit.cover),

          // Main Screen Content: Logo & Header
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: Spacing.xxl),
                Image.asset(
                  AppAssets.authLogoWhite,
                  width: Spacing.xxxl * 3,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  locale.driverAppName,
                  style: getMediumStyle(
                    color: color.onPrimary,
                    fontSize: FontSize.size12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Loading Phase indicator (at bottom)
          if (_isLoading)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    Text(
                      locale.splashHeadline,
                      style: getSemiBoldStyle(
                        color: color.onPrimary,
                        fontSize: FontSize.size20,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      locale.splashSubtitle,
                      style: getRegularStyle(
                        color: color.primaryContainer,
                        fontSize: FontSize.size12,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xxxl),
                    SizedBox.square(
                      dimension: Spacing.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: Spacing.hairline * 5,
                        color: color.onPrimary,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      locale.loading,
                      style: getRegularStyle(
                        color: color.onPrimary,
                        fontSize: FontSize.size12,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xxl),
                  ],
                ),
              ),
            ),

          // Background Dimmer when dialog appears
          if (!_isLoading)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: color.scrim.withValues(alpha: 0.35)),
            ),

          // Sliding Role Selection Dialog/Sheet
          if (!_isLoading)
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: AccountTypeBottomSheet(
                  selectedRole: _selectedRole,
                  roles: _roles,
                  isLoading: _isLoadingRoles,
                  isNavigating: _isNavigating,
                  failure: _rolesFailure,
                  onRetry: _fetchRoles,
                  onRoleChanged: (role) {
                    setState(() {
                      _selectedRole = role;
                    });
                  },
                  onConfirm: _navigateToLogin,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/user_role.dart';
import '../widgets/account_type_bottom_sheet.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  UserRole _selectedRole = UserRole.driver;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _loadingTimer = Timer(const Duration(seconds: 2), _onLoadingFinished);
  }

  void _onLoadingFinished() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  void _navigateToLogin() {
    if (!mounted) return;
    context.pushReplacementNamed(
      AppRoutes.login,
      arguments: _selectedRole,
    );
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
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
          Image.asset(
            AppAssets.authSplashBackground,
            fit: BoxFit.cover,
          ),

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
              child: Container(
                color: color.scrim.withValues(alpha: 0.35),
              ),
            ),

          // Sliding Role Selection Dialog/Sheet
          if (!_isLoading)
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: AccountTypeBottomSheet(
                  selectedRole: _selectedRole,
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

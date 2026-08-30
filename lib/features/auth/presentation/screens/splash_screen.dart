import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/extensions/extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _openLogin);
  }

  void _openLogin() {
    if (!mounted) {
      return;
    }

    context.pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetsFake.authSplashBackground, fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Image.asset(
                    AssetsFake.authLogo,
                    width: Spacing.xxxl * 3,
                    fit: BoxFit.contain,
                  ),
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
        ],
      ),
    );
  }
}

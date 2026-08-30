import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import 'registration_step_progress.dart';

class RegistrationScaffold extends StatelessWidget {
  const RegistrationScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.currentStep,
  });

  final String title;
  final String? subtitle;
  final int? currentStep;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: subtitle == null ? Spacing.xxl : Spacing.md),
              Text(
                title,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: subtitle == null
                      ? FontSize.size18
                      : FontSize.size14,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle!,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size10,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (currentStep != null) ...[
                const SizedBox(height: Spacing.xxl),
                RegistrationStepProgress(currentStep: currentStep!),
              ],
              const SizedBox(height: Spacing.base),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

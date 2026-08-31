import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/custom_app_bar.dart';
import 'registration_step_progress.dart';

class RegistrationScaffold extends StatelessWidget {
  const RegistrationScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.currentStep,
    this.onBackPressed,
  });

  final String title;
  final String? subtitle;
  final int? currentStep;
  final VoidCallback? onBackPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(title: title, onBackPressed: onBackPressed),
      backgroundColor: color.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subtitle != null) ...[
                const SizedBox(height: Spacing.md),
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
                SizedBox(height: subtitle == null ? Spacing.xxl : Spacing.md),
                RegistrationStepProgress(currentStep: currentStep!),
              ],
              const SizedBox(height: Spacing.base),
              Expanded(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

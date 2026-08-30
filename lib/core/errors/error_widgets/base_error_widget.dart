import 'package:flutter/material.dart';

import '../../../config/theme/font_manager.dart';
import '../../../config/theme/spacing.dart';
import '../../../config/theme/styles_manager.dart';
import '../../widget/app_button.dart';

class BaseErrorWidget extends StatelessWidget {
  const BaseErrorWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onRetry,
    this.onSecondaryAction,
    this.secondaryActionText,
    this.primaryColor,
    this.retryText = 'Retry',
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionText;
  final Color? primaryColor;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = primaryColor ?? colorScheme.error;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Icon(icon, size: 56, color: accent),
              ),
            ),
            const SizedBox(height: Spacing.xl),
            Text(
              title,
              style: getSemiBoldStyle(
                color: colorScheme.onSurface,
                fontSize: FontSize.size20,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              description,
              style: getRegularStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: FontSize.size14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Spacing.xl),
              AppButton(text: retryText, onPressed: onRetry),
            ],
            if (onSecondaryAction != null && secondaryActionText != null) ...[
              const SizedBox(height: Spacing.md),
              AppButton(
                text: secondaryActionText!,
                onPressed: onSecondaryAction,
                variant: AppButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

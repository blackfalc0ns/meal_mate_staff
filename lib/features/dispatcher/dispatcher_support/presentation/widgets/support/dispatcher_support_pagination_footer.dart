import 'package:flutter/material.dart';
import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';

class DispatcherSupportPaginationFooter extends StatelessWidget {
  const DispatcherSupportPaginationFooter({
    super.key,
    required this.isLoading,
    this.hasError = false,
    this.onRetry,
  });

  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && !hasError) {
      return const SizedBox(height: Spacing.lg);
    }

    final color = context.colorScheme;
    final locale = context.localization;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.supportLoadingMore,
                style: getRegularStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // hasError
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Center(
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 16, color: color.error),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.supportRetryLoadingMore,
                  style: getSemiBoldStyle(
                    fontSize: FontSize.size11,
                    color: color.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

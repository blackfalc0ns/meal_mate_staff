import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../../config/theme/spacing.dart';
import '../../../config/theme/text_styles.dart';
import '../../network/failures.dart';

class InlineApiErrorWidget extends StatelessWidget {
  const InlineApiErrorWidget({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.errorSurface),
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(failure.errorMessage, style: AppTextStyles.bodySmall),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

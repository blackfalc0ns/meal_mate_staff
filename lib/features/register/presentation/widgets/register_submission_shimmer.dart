import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/shimmer_widget.dart';

class RegisterSubmissionShimmer extends StatelessWidget {
  const RegisterSubmissionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Center(
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerWidget(width: 48, height: 48, borderRadius: 24),
            SizedBox(height: Spacing.md),
            ShimmerWidget(width: 140, height: 16, borderRadius: 4),
            SizedBox(height: Spacing.sm),
            ShimmerWidget(width: 100, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

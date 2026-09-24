import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/shimmer_widget.dart';

class RegisterPersonalDataShimmer extends StatelessWidget {
  const RegisterPersonalDataShimmer({super.key});

  Widget _buildFieldPlaceholder() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerWidget(width: 90, height: 14, borderRadius: 4),
        SizedBox(height: Spacing.sm),
        ShimmerWidget(
          height: Spacing.registrationFieldInputHeight,
          borderRadius: Spacing.registrationRadius,
        ),
      ],
    );
  }

  Widget _buildSectionPlaceholder(
    BuildContext context, {
    required int fieldCount,
  }) {
    final color = context.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              ShimmerWidget(width: 28, height: 28, borderRadius: 6),
              SizedBox(width: Spacing.sm),
              ShimmerWidget(width: 120, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: Spacing.md),
          for (var i = 0; i < fieldCount; i++) ...[
            if (i > 0) const SizedBox(height: Spacing.registrationFieldGap),
            _buildFieldPlaceholder(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionPlaceholder(context, fieldCount: 1),
        _buildSectionPlaceholder(context, fieldCount: 7),
        _buildSectionPlaceholder(context, fieldCount: 2),
        const SizedBox(height: Spacing.sm),
        const ShimmerWidget(
          height: Spacing.registrationButtonHeight,
          borderRadius: Spacing.registrationRadius,
        ),
        const SizedBox(height: Spacing.screenV),
      ],
    );
  }
}

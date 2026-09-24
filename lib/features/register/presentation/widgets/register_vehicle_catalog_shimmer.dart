import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/shimmer_widget.dart';

class RegisterVehicleCatalogShimmer extends StatelessWidget {
  const RegisterVehicleCatalogShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          ShimmerWidget(width: 20, height: 20, borderRadius: 4),
          SizedBox(width: Spacing.sm),
          Expanded(child: ShimmerWidget(height: 12, borderRadius: 4)),
          SizedBox(width: Spacing.md),
          ShimmerWidget(width: 60, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

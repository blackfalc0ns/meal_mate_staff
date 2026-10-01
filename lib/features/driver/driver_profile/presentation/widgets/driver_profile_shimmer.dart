import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/widget/shimmer_widget.dart';

class DriverProfileShimmer extends StatelessWidget {
  const DriverProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero card skeleton
        ShimmerWidget(
          height: 200,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Vehicle card skeleton
        ShimmerWidget(
          height: 110,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Support card skeleton
        ShimmerWidget(
          height: 90,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Ticket card skeleton
        ShimmerWidget(
          height: 100,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Quick actions row skeleton
        ShimmerWidget(
          height: 52,
          borderRadius: Spacing.cardRadius,
        ),
        SizedBox(height: Spacing.md),

        // Policy banner skeleton
        ShimmerWidget(
          height: 56,
          borderRadius: Spacing.cardRadius,
        ),
      ],
    );
  }
}
